import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cloudinary_service.dart';
import 'package:project_flutter/core/routes/app_routes.dart';

class EditDeckPage extends StatefulWidget {
  final String? deckId; // null = สร้าง deck ใหม่, มีค่า = แก้ไข deck ที่มีอยู่
  final Map<String, dynamic>? initialData; // legacy support
  const EditDeckPage({super.key, this.deckId, this.initialData});

  @override
  State<EditDeckPage> createState() => _EditDeckPageState();
}

class _EditDeckPageState extends State<EditDeckPage> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  late Future<void> _initFuture;
  
  String? _coverImageUrl; // URL ของรูปปกจาก Cloudinary
  bool _isUploadingCover = false;
  String? _deckIdForCards; // deckId สำหรับการเพิ่มไพ่ (สร้างตั้งแต่แรก)

  @override
  void initState() {
    super.initState();
    _initFuture = _initializePage();
  }

  // ฟังก์ชันเริ่มต้นหน้า (เฉพาะชื่อและรูปปก)
  Future<void> _initializePage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (widget.deckId != null) {
        // โหลด deck ที่มีอยู่แล้ว (editing mode)
        final deckDoc = await _firestore.collection('decks').doc(widget.deckId).get();
        if (deckDoc.exists) {
          _nameController.text = deckDoc['deck_name'] ?? '';
          
          setState(() {
            _coverImageUrl = deckDoc['cover_image'] ?? '';
            _deckIdForCards = widget.deckId; // ใช้ deckId ที่ส่งมา
          });
        }
      } else {
        // สร้าง deck ชั่วคราวทันที (create mode) เพื่อให้เพิ่มไพ่ได้เลย
        final newDeckRef = _firestore.collection('decks').doc();
        
        await newDeckRef.set({
          'deck_name': 'เด็คใหม่', // ชื่อเริ่มต้น
          'creator_id': user.uid,
          'creator_username': user.email?.split('@')[0] ?? 'Unknown',
          'cover_image': '',
          'view_count': 0,
          'draw_count': 0,
          'created_at': FieldValue.serverTimestamp(),
          'deck_status': 'unverified',
        });

        // เพิ่ม deckId เข้า my_decks ของ user
        await _firestore.collection('users').doc(user.uid).update({
          'my_decks': FieldValue.arrayUnion([newDeckRef.id]),
          'total_decks_created': FieldValue.increment(1),
        });

        setState(() {
          _deckIdForCards = newDeckRef.id; // เก็บ deckId เพื่อใช้เพิ่มไพ่
        });
      }
    } catch (e) {
      print('Error initializing page: $e');
    }
  }

  // Stream function สำหรับ real-time cards
  Stream<List<QueryDocumentSnapshot>> _getCardsStream() {
    if (_deckIdForCards == null || _deckIdForCards!.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('decks')
        .doc(_deckIdForCards)
        .collection('cards')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // ฟังก์ชันอัพโหลดรูปปกพร้อม crop
  Future<void> _uploadCoverImage() async {
    setState(() => _isUploadingCover = true);
    
    try {
      // Step 1: เลือกรูป
      final XFile? imageFile = await CloudinaryService.pickImage();
      if (imageFile == null) {
        setState(() => _isUploadingCover = false);
        return;
      }

      // Step 2: Crop รูป
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'ตัดรูปปก',
            toolbarColor: const Color(0xFF2A1B60),
            toolbarWidgetColor: Colors.white,
            backgroundColor: const Color(0xFF1E1E3A),
            activeControlsWidgetColor: Colors.amber,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            cropGridColumnCount: 3,
            cropGridRowCount: 3,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'ตัดรูปปก',
            cancelButtonTitle: 'ยกเลิก',
            doneButtonTitle: 'ยืนยัน',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: const CroppieViewPort(
              width: 480,
              height: 480,
              type: 'square',
            ),
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile == null) {
        setState(() => _isUploadingCover = false);
        return;
      }

      _showLoading('กำลังอัพโหลดรูปภาพ...');

      // Step 3: อัพโหลด cropped image ไป Cloudinary
      final imageUrl = await CloudinaryService.uploadImageFromPath(croppedFile.path);
      
      if (!mounted) return;
      Navigator.pop(context); // ปิด loading dialog

      if (imageUrl != null) {
        setState(() {
          _coverImageUrl = imageUrl;
        });
        _showSuccess('อัพโหลดรูปปกสำเร็จ!');
      } else {
        _showError('ไม่สามารถอัพโหลดรูปภาพได้');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // ปิด loading dialog
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  // ฟังก์ชันบันทึก deck (สร้างใหม่หรือแก้ไข)
  Future<void> _saveDeck() async {
    if (_nameController.text.isEmpty) {
      _showError('กรุณากรอกชื่อสำรับ');
      return;
    }

    // แสดงคำเตือนถ้าไม่มีรูปปก
    if (_coverImageUrl == null || _coverImageUrl!.isEmpty) {
      _showError('⚠️ กรุณาเพิ่มรูปปกสำรับด้วย');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_deckIdForCards == null) {
        _showError('เกิดข้อผิดพลาดในการสร้างสำรับ');
        setState(() => _isLoading = false);
        return;
      }

      // Update deck ที่สร้างไว้แล้ว
      await _firestore.collection('decks').doc(_deckIdForCards).update({
        'deck_name': _nameController.text.trim(),
        'cover_image': _coverImageUrl ?? '',
      });

      _showSuccess('บันทึกสำรับสำเร็จ!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 15),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.actionGreen),
    );
  }

  // ฟังก์ชันลบ deck ที่ไม่ได้บันทึก (เมื่อ user กดย้อนกลับในโหมดสร้างใหม่)
  Future<void> _deleteDeckIfNotSaved() async {
    try {
      // ลบเฉพาะ deck ที่สร้างใหม่ (create mode: widget.deckId == null)
      if (widget.deckId == null && _deckIdForCards != null) {
        final user = _auth.currentUser;
        if (user == null) return;

        // ลบ deck document
        await _firestore.collection('decks').doc(_deckIdForCards).delete();

        // ลบ deckId ออกจาก my_decks ของ user
        await _firestore.collection('users').doc(user.uid).update({
          'my_decks': FieldValue.arrayRemove([_deckIdForCards]),
          'total_decks_created': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      print('Error deleting deck: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            // ลบ deck ที่ไม่ได้บันทึกเมื่อ user กดย้อนกลับในโหมดสร้างใหม่
            await _deleteDeckIfNotSaved();
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          return Column(
            children: [
              // 1. ส่วนหัว (แถบสีม่วง)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: const Color(0xFF2A1B60),
                child: Center(
                  child: Text(
                    _nameController.text.isEmpty ? "ชื่อสำรับ(ตัวอย่าง)" : _nameController.text,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              // 2. ส่วนข้อมูลหลัก (Cover + Name Input)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ส่วนใส่รูปปก
                    GestureDetector(
                      onTap: () => _uploadCoverImage(),
                      child: Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[800],
                          image: _coverImageUrl != null
                              ? DecorationImage(image: NetworkImage(_coverImageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _coverImageUrl == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.white30),
                                    SizedBox(height: 8),
                                    Text('เพิ่มรูปปก', style: TextStyle(color: Colors.white30, fontSize: 12)),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // ส่วนกรอกชื่อและจำนวน
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ชื่อสำรับ", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          const Text("💡 ขนาดรูปปกที่แนะนำ: 800x1200 px", 
                            style: TextStyle(color: Colors.amber, fontSize: 11)),
                          const SizedBox(height: 8),
                          StreamBuilder<List<QueryDocumentSnapshot>>(
                            stream: _getCardsStream(),
                            builder: (context, snapshot) {
                              final cardCount = snapshot.data?.length ?? 0;
                              return Text("จำนวนไพ่ปัจจุบัน : $cardCount", 
                                style: const TextStyle(color: Colors.white70));
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // 3. ส่วนรายการการ์ด (Grid) - Real-time update
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF1E1E3A),
                  child: StreamBuilder<List<QueryDocumentSnapshot>>(
                    stream: _getCardsStream(),
                    builder: (context, snapshot) {
                      final cards = snapshot.data ?? [];

                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: cards.length + 1,
                        itemBuilder: (context, index) {
                          if (index == cards.length) {
                            return _buildSquareButton(
                              onTap: () {
                                if (_deckIdForCards == null || _deckIdForCards!.isEmpty) {
                                  _showError('เกิดข้อผิดพลาดในการสร้างสำรับ');
                                  return;
                                }
                                Navigator.pushNamed(context, AppRoutes.addCard, arguments: _deckIdForCards);
                              },
                            );
                          }

                          final card = cards[index];
                          final frontImage = card['front_image'] ?? '';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4),
                              image: frontImage.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(frontImage), fit: BoxFit.cover)
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // 4. ปุ่มยืนยันด้านล่าง
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: (_isLoading || _isUploadingCover) ? null : _saveDeck,
                    child: (_isLoading || _isUploadingCover)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "ยืนยัน",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSquareButton({double? width, double? height, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.add, size: 40, color: Colors.black54),
      ),
    );
  }
}
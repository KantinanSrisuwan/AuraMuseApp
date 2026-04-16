import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cloudinary_service.dart';

class AddCardPage extends StatefulWidget {
  final String deckId;
  const AddCardPage({super.key, required this.deckId});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _backTextController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _frontImageUrl; // URL ของรูปหน้าการ์ดจาก Cloudinary
  bool _isUploadingImage = false;
  bool _isCreating = false;

  // ฟังก์ชันอัพโหลดรูปหน้าการ์ดพร้อม crop
  Future<void> _uploadFrontImage() async {
    setState(() => _isUploadingImage = true);
    
    try {
      // Step 1: เลือกรูป
      final imageFile = await CloudinaryService.pickImage();
      if (imageFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      // Step 2: Crop รูป
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'ตัดรูป',
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
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'ตัดรูป',
            cancelButtonTitle: 'ยกเลิก',
            doneButtonTitle: 'ยืนยัน',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio5x3,
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
        setState(() => _isUploadingImage = false);
        return;
      }

      _showLoadingDialog('กำลังอัพโหลดรูปภาพ...');

      // Step 3: อัพโหลด cropped image ไป Cloudinary
      final imageUrl = await CloudinaryService.uploadImageFromPath(croppedFile.path);
      
      if (!mounted) return;
      Navigator.pop(context); // ปิด loading dialog

      if (imageUrl != null) {
        setState(() {
          _frontImageUrl = imageUrl;
        });
        _showSuccess('อัพโหลดรูปภาพสำเร็จ!');
      } else {
        _showError('ไม่สามารถอัพโหลดรูปภาพได้');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // ปิด loading dialog
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ฟังก์ชันสร้างการ์ดใหม่ใน Firebase
  Future<void> _createCard() async {
    if (_frontImageUrl == null || _frontImageUrl!.isEmpty) {
      _showError('กรุณาเลือกรูปภาพในการ์ด');
      return;
    }

    if (_backTextController.text.isEmpty) {
      _showError('กรุณากรอกข้อความหลังการ์ด');
      return;
    }

    setState(() => _isCreating = true);

    try {
      // สร้าง sub-collection 'cards' ใน deck นี้
      final newCardRef = _firestore
          .collection('decks')
          .doc(widget.deckId)
          .collection('cards')
          .doc();

      await newCardRef.set({
        'front_image': _frontImageUrl,
        'back_text': _backTextController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      _showSuccess('เพิ่มการ์ดสำเร็จ!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _showLoadingDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("สร้างการ์ดใบใหม่", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ส่วนเนื้อหาแบบ Scroll ได้
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนที่ 1: เลือกรูปภาพหน้าการ์ด ---
                  const Text("1. เลือกรูปภาพสำหรับหน้าการ์ด", 
                    style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Center(
                    child: _buildImageInput(),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text("💡 ขนาดรูปที่แนะนำ: 800x1200 px", 
                      style: TextStyle(color: Colors.amber, fontSize: 12)),
                  ),

                  const SizedBox(height: 30),

                  // --- ส่วนที่ 2: กรอกข้อความหลังการ์ด ---
                  const Text("2. กรอกข้อความสำหรับหลังการ์ด", 
                    style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildTextInput(),
                ],
              ),
            ),
          ),

          // --- ส่วนปุ่มยืนยันด้านล่าง ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (_isCreating || _isUploadingImage) ? null : _createCard,
                child: (_isCreating || _isUploadingImage)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("เพิ่มการ์ดเข้าสำรับ", 
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget พื้นที่เลือกรูปภาพ ---
  Widget _buildImageInput() {
    return GestureDetector(
      onTap: () => _uploadFrontImage(),
      child: AspectRatio(
        aspectRatio: 0.65,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D4E),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
            image: _frontImageUrl != null
                ? DecorationImage(image: NetworkImage(_frontImageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: _frontImageUrl == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 60, color: Colors.white24),
                    SizedBox(height: 10),
                    Text("แตะเพื่อเลือกและตัดรูปภาพ", style: TextStyle(color: Colors.white24)),
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      color: Colors.black26,
                    ),
                    Icon(Icons.edit, size: 40, color: Colors.white70),
                  ],
                ),
        ),
      ),
    );
  }

  // --- Widget พื้นที่กรอกข้อความ Multi-line ---
  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D4E),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _backTextController,
        maxLines: 6,
        style: const TextStyle(color: Colors.white70),
        maxLength: 300,
        decoration: const InputDecoration(
          hintText: "กรอกคำทำนาย, ความหมาย, หรือผลลัพธ์ที่นี่...",
          hintStyle: TextStyle(color: Colors.white10),
          border: InputBorder.none,
          counterStyle: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }
}
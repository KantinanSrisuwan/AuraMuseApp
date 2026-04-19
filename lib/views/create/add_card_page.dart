import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cloudinary_service.dart';

class AddCardPage extends StatefulWidget {
  final String deckId;
  final String? cardId;
  final Map<String, dynamic>? initialData;
  const AddCardPage({super.key, required this.deckId, this.cardId, this.initialData});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _backTextController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _frontImageUrl; // URL ของรูปหน้าการ์ดจาก Cloudinary
  bool _isUploadingImage = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (widget.cardId != null && widget.initialData != null) {
      _backTextController.text = widget.initialData!['back_text'] ?? '';
      _frontImageUrl = widget.initialData!['front_image'];
    }
  }

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
          ),
        ],
      );

      if (croppedFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      _showLoadingDialog('กำลังอัพโหลดรูปภาพ...');

      // Step 3: อัพโหลด cropped image ไป Cloudinary
      final bytes = await croppedFile.readAsBytes();
      final imageUrl = await CloudinaryService.uploadImageFromBytes(bytes, 'cropped_image.png');
      
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

  // ฟังก์ชันสร้างการ์ดใหม่หรือแก้ไขใน Firebase
  Future<void> _saveCard() async {
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
      if (widget.cardId != null) {
        // อัปเดตการ์ดเดิม (โหมดแก้ไข)
        await _firestore
            .collection('decks')
            .doc(widget.deckId)
            .collection('cards')
            .doc(widget.cardId)
            .update({
          'front_image': _frontImageUrl,
          'back_text': _backTextController.text.trim(),
        });

        _showSuccess('บันทึกการแก้ไขสำเร็จ!');
      } else {
        // สร้างการ์ดใหม่
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
      }
      
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.cardId != null ? "แก้ไขการ์ด" : "สร้างการ์ดใบใหม่", 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: SafeArea(
          child: Column(
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
                        style: TextStyle(color: AppColors.cosmicCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Center(
                        child: _buildImageInput(),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text("💡 ขนาดรูปที่แนะนำ: 800x1200 px", 
                          style: TextStyle(color: AppColors.actionAmber, fontSize: 12)),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 40),

                      // --- ส่วนที่ 2: กรอกข้อความหลังการ์ด ---
                      const Text("2. กรอกข้อความสำหรับหลังการ์ด", 
                        style: TextStyle(color: AppColors.cosmicCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildTextInput().animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                    ],
                  ),
                ),
              ),

              // --- ส่วนปุ่มยืนยันด้านล่าง ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryActionGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cosmicCyan.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (_isCreating || _isUploadingImage) ? null : _saveCard,
                    child: (_isCreating || _isUploadingImage)
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(widget.cardId != null ? "บันทึกการแก้ไข" : "เพิ่มการ์ดเข้าสำรับ", 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ).animate().slideY(begin: 0.5, delay: 600.ms),
              ),
            ],
          ),
        ),
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
          decoration: AppColors.glassDecoration(radius: 15).copyWith(
            image: _frontImageUrl != null
                ? DecorationImage(image: NetworkImage(_frontImageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: _frontImageUrl == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 60, color: AppColors.cosmicCyan),
                    SizedBox(height: 10),
                    Text("แตะเพื่อเลือกและตัดรูปภาพ", style: TextStyle(color: AppColors.textWhiteMuted)),
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      color: Colors.black45,
                    ),
                    const Icon(Icons.edit, size: 40, color: Colors.white70),
                  ],
                ),
        ),
      ),
    );
  }

  // --- Widget พื้นที่กรอกข้อความ Multi-line ---
  Widget _buildTextInput() {
    return Container(
      decoration: AppColors.glassDecoration(radius: 12),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _backTextController,
        maxLines: 6,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppColors.cosmicCyan,
        maxLength: 300,
        decoration: const InputDecoration(
          hintText: "กรอกคำทำนาย, ความหมาย, หรือผลลัพธ์ที่นี่...",
          hintStyle: TextStyle(color: AppColors.textWhiteFaded),
          border: InputBorder.none,
          counterStyle: TextStyle(color: AppColors.textWhiteMuted),
        ),
      ),
    );
  }
}
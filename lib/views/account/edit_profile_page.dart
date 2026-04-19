import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  bool _isLoading = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _usernameFocus.addListener(() {
      setState(() {
        _isFocused = _usernameFocus.hasFocus;
      });
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _usernameController.text = doc.data()?['username'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_usernameController.text.trim().isEmpty) {
      _showSnackbar("กรุณากรอกชื่อผู้ใช้", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'username': _usernameController.text.trim(),
        });
        
        if (mounted) {
          _showSnackbar("อัปเดตข้อมูลสำเร็จ ✨");
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showSnackbar("เกิดข้อผิดพลาด: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppColors.errorRed : AppColors.actionGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "แก้ไขบัญชี",
          style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Profile Icon with Glow
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cosmicCyan.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.backgroundNavyLight,
                  child: Icon(Icons.account_circle, size: 100, color: AppColors.cosmicCyan),
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),

            const SizedBox(height: 50),
            
            // Username Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Username",
                  style: TextStyle(color: AppColors.textWhiteMuted, fontSize: 16),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: 300.ms,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (_isFocused)
                        BoxShadow(
                          color: AppColors.cosmicCyan.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    focusNode: _usernameFocus,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      hintText: "กรอกชื่อผู้ใช้ของคุณ",
                      hintStyle: TextStyle(color: AppColors.textWhite.withOpacity(0.3)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.glassBorder, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.cosmicCyan, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                  ),
                ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutBack).fadeIn(delay: 300.ms),
              ],
            ),
            
            const SizedBox(height: 60),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.primaryActionGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cosmicCyan.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          "ยืนยันการแก้ไข",
                          style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
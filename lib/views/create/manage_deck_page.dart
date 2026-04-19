import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import 'edit_deck_page.dart';

class ManageDeckPage extends StatefulWidget {
  const ManageDeckPage({super.key});

  @override
  State<ManageDeckPage> createState() => _ManageDeckPageState();
}

class _ManageDeckPageState extends State<ManageDeckPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream function สำหรับ real-time monitoring
  Stream<List<DocumentSnapshot>> _getMyDecksStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    // Listen ที่ user document เพื่อได้ my_decks array ที่เปลี่ยนแปลง
    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return [];

      final myDeckIds = List<String>.from(userDoc['my_decks'] ?? []);
      if (myDeckIds.isEmpty) return [];

      // ดึง deck documents ทั้งหมด
      List<DocumentSnapshot> decks = [];
      for (String deckId in myDeckIds) {
        try {
          final deckDoc = await _firestore
              .collection('decks')
              .doc(deckId)
              .get();
          if (deckDoc.exists) {
            decks.add(deckDoc);
          }
        } catch (e) {
          print('Error fetching deck: $e');
        }
      }
      return decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  "จัดการสำรับของฉัน",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ).animate().fadeIn(duration: 400.ms),
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _getMyDecksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cosmicCyan,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final decks = snapshot.data ?? [];

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: decks.length + 1, // รวมปุ่มเพิ่มท้ายที่สุด
                      itemBuilder: (context, index) {
                        if (index == decks.length) {
                          return _buildAddBtn(context)
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 100 * index),
                              )
                              .scale();
                        }
                        return _buildDeckItem(context, decks[index], index)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 50 * index))
                            .scale();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddBtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // รอให้ EditDeckPage เสร็จ (สร้าง deck ใหม่โดยไม่ระบุ deckId)
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditDeckPage()),
        );
        // หลังจากกลับมา ให้ setState เพื่อ rebuild Stream
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cosmicCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cosmicCyan.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.cosmicCyan,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              "Create",
              style: TextStyle(
                color: AppColors.cosmicCyan,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckItem(
    BuildContext context,
    DocumentSnapshot deck,
    int index,
  ) {
    final String coverImage = deck['cover_image'] ?? '';
    final String deckId = deck.id;

    return GestureDetector(
      onTap: () async {
        // รอให้ EditDeckPage เสร็จ
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditDeckPage(deckId: deckId)),
        );
        // หลังจากกลับมา ให้ setState เพื่อ rebuild Stream
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: coverImage.isNotEmpty
              ? Image.network(
                  coverImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.glassBorder,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cosmicCyan,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.glassBorder,
                    child: const Center(
                      child: Icon(Icons.style, color: Colors.white30, size: 30),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.glassBorder,
                  child: const Center(
                    child: Icon(Icons.style, color: Colors.white30, size: 30),
                  ),
                ),
        ),
      ),
    );
  }
}

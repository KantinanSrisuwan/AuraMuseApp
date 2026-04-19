import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../home/draw_result_page.dart';

class DeckListPage extends StatefulWidget {
  final dynamic deckData; // QueryDocumentSnapshot
  const DeckListPage({super.key, this.deckData});

  @override
  State<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  late Future<List<QueryDocumentSnapshot>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = _fetchCards();
  }

  // ฟังก์ชันดึง cards จาก sub-collection
  Future<List<QueryDocumentSnapshot>> _fetchCards() async {
    try {
      final deckId = widget.deckData?.id ?? '';
      if (deckId.isEmpty) return [];
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();
      
      return snapshot.docs;
    } catch (e) {
      print('Error fetching cards: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String deckName = widget.deckData?['deck_name'] ?? "สำรับไพ่";
    final String deckId = widget.deckData?.id ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: SafeArea(
          child: FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _cardsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.cosmicCyan),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text("เกิดข้อผิดพลาดในการโหลดไพ่", style: TextStyle(color: Colors.redAccent)),
                );
              }

              final cards = snapshot.data ?? [];

              return Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.cosmicCyan).animate().moveY(begin: -5, end: 5, duration: 1.seconds, curve: Curves.easeInOut).fadeIn(),
                  const Text("ปัดลงเพื่อกลับไปหน้าปก", style: TextStyle(color: AppColors.cosmicCyan, fontSize: 12)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: AppColors.glassDecoration(radius: 20),
                    child: Text(
                      deckName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2),
                  const SizedBox(height: 20),
              Expanded(
                child: cards.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final frontImage = card['front_image'] ?? '';
                          final cardId = card.id; // ดึง card ID จาก Firestore
                          
                          return GestureDetector(
                            onTap: () {
                              // ส่ง cardId ไปให้ DrawResultPage เพื่อแสดงไพ่ที่ถูกต้อง
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DrawResultPage(
                                    deckId: deckId,
                                    deckName: deckName,
                                    cardId: cardId, // ส่ง cardId ของไพ่ที่กดเข้า
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: frontImage.isNotEmpty
                                    ? Image.network(
                                        frontImage,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: AppColors.glassBorder,
                                            child: const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.cosmicCyan),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              color: AppColors.glassBorder,
                                              child: const Center(child: Icon(Icons.style, color: Colors.white30, size: 30)),
                                            ),
                                      )
                                    : Container(
                                        color: AppColors.glassBorder,
                                        child: const Center(child: Icon(Icons.style, color: Colors.white30, size: 30)),
                                      ),
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).scale(),
                          );
                        },
                      )
                    : const Center(
                        child: Text("ไม่มีไพ่ในเด็คนี้", style: TextStyle(color: AppColors.textWhiteMuted)),
                      ),
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}
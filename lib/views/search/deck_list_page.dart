import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      backgroundColor: AppColors.backgroundNavy,
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("เกิดข้อผิดพลาดในการโหลดไพ่", style: TextStyle(color: Colors.white)),
            );
          }

          final cards = snapshot.data ?? [];

          return Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
              const Text("ปัดลงเพื่อกลับไปหน้าปก", style: TextStyle(color: Colors.white24, fontSize: 12)),
              const SizedBox(height: 20),
              Text(deckName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DrawResultPage(deckId: deckId, deckName: deckName)));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: frontImage.isNotEmpty
                                  ? Image.network(
                                      frontImage,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey[800],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            color: Colors.grey[800],
                                            child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
                                          ),
                                    )
                                  : Container(
                                      color: Colors.grey[800],
                                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
                                    ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text("ไม่มีไพ่ในเด็คนี้", style: TextStyle(color: Colors.white70)),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
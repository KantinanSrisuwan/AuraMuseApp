import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import 'draw_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDeckIndex = 0;
  final PageController _pageController = PageController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QueryDocumentSnapshot>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = _fetchDecks(); // ดึงข้อมูลจากคอลเลกชัน decks
  }

  Future<List<QueryDocumentSnapshot>> _fetchDecks() async {
    try {
      // ดึงข้อมูลทั้งหมดจาก Firestore เพื่อมาแสดงผล
      QuerySnapshot snapshot = await _firestore.collection('decks').get();
      return snapshot.docs;
    } catch (e) {
      print('Error fetching decks: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy, // ใช้สีพื้นหลังที่ตั้งค่าไว้
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีเด็คให้เลือก',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final decks = snapshot.data!;

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10), // ลดระยะห่างด้านบนสุดลง
                _buildDeckSelector(decks),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: decks.length,
                    onPageChanged: (index) {
                      setState(() => _selectedDeckIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildDeckCard(index, decks);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onDeckSelected(int index, List<QueryDocumentSnapshot> decks) {
    setState(() => _selectedDeckIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDeckSelector(List<QueryDocumentSnapshot> decks) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: decks.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          bool isSelected = _selectedDeckIndex == index;
          final deckName = decks[index]['deck_name'] ?? 'DECK ${index + 1}'; // ดึงชื่อเด็คจากฟิลด์ deck_name
          
          return GestureDetector(
            onTap: () => _onDeckSelected(index, decks),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    deckName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white30,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4), 
                      height: 2,
                      width: 40,
                      color: Colors.white,
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeckCard(int index, List<QueryDocumentSnapshot> decks) {
    final deck = decks[index];
    final deckId = deck.id;
    final deckName = deck['deck_name'] ?? 'DECK ${index + 1}';
    final coverImage = deck['cover_image'] ?? ''; // ดึง URL รูปจาก Cloudinary ที่เก็บในฟิลด์ cover_image

    return Align(
      alignment: const Alignment(0, -0.4), // ขยับไพ่ขึ้นด้านบนเพื่อลดช่องว่างที่เหลือเฟือ
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) => 
                  DrawResultPage(deckId: deckId, deckName: deckName),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75, // คุมความกว้างกรอบที่ 75% ของหน้าจอ
          child: AspectRatio(
            aspectRatio: 2 / 3, // บังคับสัดส่วนกรอบให้เป็น 2:3 เพื่อให้รูปไพ่แสดงผลได้เต็มโดยไม่โดนบีบ
            child: Hero(
              tag: 'deck_card_$deckId',
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2140),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          coverImage,
                          fit: BoxFit.cover, // เมื่อกรอบเป็น 2:3 แล้ว cover จะทำให้รูปเต็มพอดีและโดนตัดขอบน้อยมาก
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.style, size: 100, color: Colors.white10)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: Colors.amber));
                          },
                        ),
                      )
                    : const Center(child: Icon(Icons.style, size: 100, color: Colors.white10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
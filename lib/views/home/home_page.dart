import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<List<DocumentSnapshot>> _quickDrawsStream;

  @override
  void initState() {
    super.initState();
    _quickDrawsStream = _getQuickDrawsStream();
  }

  // Stream function สำหรับ real-time quick_draws
  Stream<List<DocumentSnapshot>> _getQuickDrawsStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    // Listen user document เพื่อดู quick_draws array
    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) {
        print('User document not found');
        return [];
      }

      // ดึง quick_draws array
      final quickDrawIds = List<String>.from(userDoc['quick_draws'] ?? []);
      print('Quick draws IDs: $quickDrawIds');

      if (quickDrawIds.isEmpty) {
        print('No quick draws found');
        return [];
      }

      // ดึง deck documents ทั้งหมดจาก quick_draws
      List<DocumentSnapshot> decks = [];
      for (String deckId in quickDrawIds) {
        try {
          final deckDoc = await _firestore
              .collection('decks')
              .doc(deckId)
              .get();
          if (deckDoc.exists) {
            print('Found deck: $deckId - ${deckDoc['deck_name']}');
            decks.add(deckDoc);
          } else {
            print('Deck not found: $deckId');
          }
        } catch (e) {
          print('Error fetching deck $deckId: $e');
        }
      }
      print('Total decks loaded: ${decks.length}');
      return decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _quickDrawsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
            return Center(
              child: Text(
                'เกิดข้อผิดพลาด: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No data or empty decks');
            return const Center(
              child: Text(
                'ไม่มีเด็คให้เลือก\nโปรดเพิ่มเด็คไปยัง Quick Draws',
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          final decks = snapshot.data ?? [];

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Quick Draw",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart),
                const SizedBox(height: 10),
                _buildDeckSelector(decks)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 90.0,
                    ), // Padding below content to clear Navbar
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onDeckSelected(int index, List<DocumentSnapshot> decks) {
    setState(() => _selectedDeckIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDeckSelector(List<DocumentSnapshot> decks) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: decks.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          bool isSelected = _selectedDeckIndex == index;
          final deckName = decks[index]['deck_name'] ?? 'DECK ${index + 1}';

          return GestureDetector(
            onTap: () => _onDeckSelected(index, decks),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cosmicCyan.withOpacity(0.15)
                    : AppColors.glassBorder,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cosmicCyan.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  deckName,
                  style: TextStyle(
                    color: isSelected ? AppColors.cosmicCyan : Colors.white54,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeckCard(int index, List<DocumentSnapshot> decks) {
    final deck = decks[index];
    final deckId = deck.id;
    final deckName = deck['deck_name'] ?? 'DECK ${index + 1}';
    final coverImage = deck['cover_image'] ?? '';
    final isSelected = index == _selectedDeckIndex;

    return Align(
      alignment: const Alignment(0, -0.2),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DrawResultPage(deckId: deckId, deckName: deckName),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        },
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.85,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Hero(
                  tag: 'deck_card_$deckId',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2140),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.cosmicPurple.withOpacity(0.8)
                            : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.cosmicPurple.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: -10,
                            offset: const Offset(0, 15),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                      ],
                    ),
                    child: coverImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              coverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.style,
                                      size: 80,
                                      color: Colors.white10,
                                    ),
                                  ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.cosmicCyan.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.style,
                              size: 80,
                              color: Colors.white10,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

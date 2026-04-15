import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../search/deck_view_wrapper.dart';

class MyDeckPage extends StatefulWidget {
  const MyDeckPage({super.key});

  @override
  State<MyDeckPage> createState() => _MyDeckPageState();
}

class _MyDeckPageState extends State<MyDeckPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ฟังก์ชันดึง my_decks (ใช้ Future แทน Stream เพื่อหลีกเลี่ยง memory leak)
  Future<List<DocumentSnapshot>> _fetchMyDecks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return [];

      final myDeckIds = List<String>.from(userDoc['my_decks'] ?? []);
      if (myDeckIds.isEmpty) return [];

      List<DocumentSnapshot> decks = [];
      for (String deckId in myDeckIds) {
        try {
          final deckDoc = await _firestore.collection('decks').doc(deckId).get();
          if (deckDoc.exists) {
            decks.add(deckDoc);
          }
        } catch (e) {
          print('Error fetching my_deck: $e');
        }
      }
      return decks;
    } catch (e) {
      print('Error fetching my decks: $e');
      return [];
    }
  }

  // ฟังก์ชันดึง favorites
  Future<List<DocumentSnapshot>> _fetchFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return [];

      final favoriteIds = List<String>.from(userDoc['favorites'] ?? []);
      if (favoriteIds.isEmpty) return [];

      List<DocumentSnapshot> decks = [];
      for (String deckId in favoriteIds) {
        try {
          final deckDoc = await _firestore.collection('decks').doc(deckId).get();
          if (deckDoc.exists) {
            decks.add(deckDoc);
          }
        } catch (e) {
          print('Error fetching favorite: $e');
        }
      }
      return decks;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // ฟังก์ชันดึง quick_draws
  Future<List<DocumentSnapshot>> _fetchQuickDraws() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return [];

      final quickDrawIds = List<String>.from(userDoc['quick_draws'] ?? []);
      if (quickDrawIds.isEmpty) return [];

      List<DocumentSnapshot> decks = [];
      for (String deckId in quickDrawIds) {
        try {
          final deckDoc = await _firestore.collection('decks').doc(deckId).get();
          if (deckDoc.exists) {
            decks.add(deckDoc);
          }
        } catch (e) {
          print('Error fetching quick_draw: $e');
        }
      }
      return decks;
    } catch (e) {
      print('Error fetching quick_draws: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNavy,
        body: SafeArea( 
          child: Column(
            children: [
              const TabBar(
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.amber,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  Tab(text: "Deck ของฉัน"),
                  Tab(text: "รายการโปรด"),
                  Tab(text: "Quick Draw"),
                ],
              ),
              
              Expanded(
                child: TabBarView(
                  children: [
                    _buildDeckGridWithFuture(_fetchMyDecks(), showAddButton: true),
                    _buildDeckGridWithFuture(_fetchFavorites()),
                    _buildDeckGridWithFuture(_fetchQuickDraws()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง Grid แสดงผล Deck จาก Future
  Widget _buildDeckGridWithFuture(Future<List<DocumentSnapshot>> future, {bool showAddButton = false}) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        final decks = snapshot.data ?? [];

        if (decks.isEmpty && !showAddButton) {
          return const Center(
            child: Text(
              'ไม่มีสำรับไพ่',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.65,
          ),
          itemCount: showAddButton ? decks.length + 1 : decks.length,
          itemBuilder: (context, index) {
            if (showAddButton && index == decks.length) {
              return _buildAddButton();
            }

            final deck = decks[index];
            final deckName = deck['deck_name'] ?? 'สำรับไพ่';
            final coverImage = deck['cover_image'] ?? '';
            final deckId = deck.id;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim, secAnim) => const DeckViewWrapper(),
                    settings: RouteSettings(arguments: deck),
                    transitionsBuilder: (context, anim, secAnim, child) {
                      return FadeTransition(opacity: anim, child: child);
                    },
                  ),
                );
              },
              child: Hero(
                tag: 'deck_hero_$deckId',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white10,
                              child: const Icon(Icons.broken_image, color: Colors.white24),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: Colors.white.withOpacity(0.05));
                          },
                        )
                      : Container(
                          color: Colors.white10,
                          child: const Icon(Icons.broken_image, color: Colors.white24),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ปุ่มสร้างสำรับใหม่ (+)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/manage_deck');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: const Icon(Icons.add, color: Colors.white38, size: 40),
      ),
    );
  }
}
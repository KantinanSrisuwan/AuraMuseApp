import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../create/edit_deck_page.dart';

class MyDeckPage extends StatefulWidget {
  const MyDeckPage({super.key});

  @override
  State<MyDeckPage> createState() => _MyDeckPageState();
}

class _MyDeckPageState extends State<MyDeckPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (mounted) {
      setState(() {
        _lastRefreshTime = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        print('MyDeckPage: App resumed - forcing refresh');
        setState(() {
          _lastRefreshTime = DateTime.now();
        });
      }
    }
  }

  // Stream function สำหรับ my_decks (listen real-time)
  Stream<List<DocumentSnapshot>> _getMyDecksStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>?;
      final myDeckIds = List<String>.from(userData?['my_decks'] ?? []);
      if (myDeckIds.isEmpty) return [];

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
          print('Error fetching my_deck: $e');
        }
      }
      return decks;
    });
  }

  // Stream function สำหรับ favorites (listen real-time)
  Stream<List<DocumentSnapshot>> _getFavoritesStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>?;
      final favoriteIds = List<String>.from(userData?['favorites'] ?? []);
      if (favoriteIds.isEmpty) return [];

      List<DocumentSnapshot> decks = [];
      for (String deckId in favoriteIds) {
        try {
          final deckDoc = await _firestore
              .collection('decks')
              .doc(deckId)
              .get();
          if (deckDoc.exists) {
            decks.add(deckDoc);
          }
        } catch (e) {
          print('Error fetching favorite: $e');
        }
      }
      return decks;
    });
  }

  // Stream function สำหรับ quick_draws (listen real-time)
  Stream<List<DocumentSnapshot>> _getQuickDrawsStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>?;
      final quickDrawIds = List<String>.from(userData?['quick_draws'] ?? []);
      if (quickDrawIds.isEmpty) return [];

      List<DocumentSnapshot> decks = [];
      for (String deckId in quickDrawIds) {
        try {
          final deckDoc = await _firestore
              .collection('decks')
              .doc(deckId)
              .get();
          if (deckDoc.exists) {
            decks.add(deckDoc);
          }
        } catch (e) {
          print('Error fetching quick_draw: $e');
        }
      }
      return decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppColors.cosmicCyan.withOpacity(0.2),
                  border: Border.all(color: AppColors.cosmicCyan, width: 1),
                ),
                labelColor: AppColors.cosmicCyan,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: "My Decks"),
                  Tab(text: "Favorites"),
                  Tab(text: "Quick Draw"),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeckGridWithStream(
                    _getMyDecksStream(),
                    showAddButton: true,
                  ),
                  _buildDeckGridWithStream(_getFavoritesStream()),
                  _buildDeckGridWithStream(_getQuickDrawsStream()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckGridWithStream(
    Stream<List<DocumentSnapshot>> stream, {
    bool showAddButton = false,
  }) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: stream,
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
            final coverImage = deck['cover_image'] ?? '';
            final deckId = deck.id;

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/deck_detail', arguments: deck);
              },
              child:
                  Container(
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
                                  key: ValueKey(coverImage),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.glassBorder,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white24,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: AppColors.glassBorder,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.cosmicCyan
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : Container(
                                  color: AppColors.glassBorder,
                                  child: const Icon(
                                    Icons.style,
                                    color: Colors.white24,
                                    size: 40,
                                  ),
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                      .scale(curve: Curves.easeOutQuart),
            );
          },
        );
      },
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditDeckPage()),
        );
        if (mounted) {
          setState(() {
            _lastRefreshTime = DateTime.now();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cosmicCyan.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          color: AppColors.cosmicCyan.withOpacity(0.1),
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
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(curve: Curves.easeOutQuart),
    );
  }
}

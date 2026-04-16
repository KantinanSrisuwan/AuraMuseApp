import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../search/deck_view_wrapper.dart';
import '../create/edit_deck_page.dart';
import '../create/manage_deck_page.dart';

class MyDeckPage extends StatefulWidget {
  const MyDeckPage({super.key});

  @override
  State<MyDeckPage> createState() => _MyDeckPageState();
}

class _MyDeckPageState extends State<MyDeckPage> with WidgetsBindingObserver, TickerProviderStateMixin {
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

    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap(
      (userDoc) async {
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
      },
    );
  }

  // Stream function สำหรับ favorites (listen real-time)
  Stream<List<DocumentSnapshot>> _getFavoritesStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap(
      (userDoc) async {
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
      },
    );
  }

  // Stream function สำหรับ quick_draws (listen real-time)
  Stream<List<DocumentSnapshot>> _getQuickDrawsStream() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore.collection('users').doc(user.uid).snapshots().asyncMap(
      (userDoc) async {
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SafeArea( 
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.amber,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: const [
                Tab(text: "Deck ของฉัน"),
                Tab(text: "รายการโปรด"),
                Tab(text: "Quick Draw"),
              ],
            ),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeckGridWithStream(_getMyDecksStream(), showAddButton: true),
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

  Widget _buildDeckGridWithStream(Stream<List<DocumentSnapshot>> stream, {bool showAddButton = false}) {
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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim, secAnim) => EditDeckPage(deckId: deckId),
                    transitionsBuilder: (context, anim, secAnim, child) {
                      return FadeTransition(opacity: anim, child: child);
                    },
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: coverImage.isNotEmpty
                    ? Image.network(
                        coverImage,
                        fit: BoxFit.cover,
                        key: ValueKey(coverImage),
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
            );
          },
        );
      },
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        // สร้าง deck ใหม่โดยไม่ระบุ deckId
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: const Icon(Icons.add, color: Colors.white38, size: 40),
      ),
    );
  }
}
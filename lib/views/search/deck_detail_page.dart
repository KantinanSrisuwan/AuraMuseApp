import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../home/draw_result_page.dart';

class DeckDetailPage extends StatefulWidget {
  final dynamic deckData; // QueryDocumentSnapshot
  const DeckDetailPage({super.key, this.deckData});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  bool _isFavorite = false;
  bool _isQuickDraw = false;
  late Future<int> _cardCountFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _cardCountFuture = _getCardCount();
    _incrementViewCount();
    _checkUserPreferences();
  }

  // ฟังก์ชันเพิ่ม view_count ของ deck
  Future<void> _incrementViewCount() async {
    try {
      final deckId = widget.deckData?.id ?? '';
      if (deckId.isEmpty) return;

      await _firestore.collection('decks').doc(deckId).update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view_count: $e');
    }
  }

  // ฟังก์ชันตรวจสอบว่า deck นี้อยู่ใน favorites หรือ quick_draws หรือไม่
  Future<void> _checkUserPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final deckId = widget.deckData?.id ?? '';
      if (deckId.isEmpty) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final favorites = List<String>.from(userDoc['favorites'] ?? []);
        final quickDraws = List<String>.from(userDoc['quick_draws'] ?? []);

        setState(() {
          _isFavorite = favorites.contains(deckId);
          _isQuickDraw = quickDraws.contains(deckId);
        });
      }
    } catch (e) {
      print('Error checking user preferences: $e');
    }
  }

  // ฟังก์ชันเพิ่ม/ลบ deck จาก favorites
  Future<void> _toggleFavorite() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final deckId = widget.deckData?.id ?? '';
      if (deckId.isEmpty) return;

      final userRef = _firestore.collection('users').doc(user.uid);

      if (_isFavorite) {
        // ลบออกจาก favorites
        await userRef.update({
          'favorites': FieldValue.arrayRemove([deckId]),
        });
      } else {
        // เพิ่มเข้า favorites
        await userRef.update({
          'favorites': FieldValue.arrayUnion([deckId]),
        });
      }

      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // ฟังก์ชันเพิ่ม/ลบ deck จาก quick_draws
  Future<void> _toggleQuickDraw() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final deckId = widget.deckData?.id ?? '';
      if (deckId.isEmpty) return;

      final userRef = _firestore.collection('users').doc(user.uid);

      if (_isQuickDraw) {
        // ลบออกจาก quick_draws
        await userRef.update({
          'quick_draws': FieldValue.arrayRemove([deckId]),
        });
      } else {
        // เพิ่มเข้า quick_draws
        await userRef.update({
          'quick_draws': FieldValue.arrayUnion([deckId]),
        });
      }

      setState(() => _isQuickDraw = !_isQuickDraw);
    } catch (e) {
      print('Error toggling quick_draw: $e');
    }
  }

  // ฟังก์ชันดึงจำนวนไพ่ในเด็ค
  Future<int> _getCardCount() async {
    try {
      final deckId = widget.deckData?.id ?? '';
      if (deckId.isEmpty) return 0;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting card count: $e');
      return 0;
    }
  }

  void _showReportDialog() {
    final TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "รายงานความไม่เหมาะสม",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: reportController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "เหตุผลของคุณ...",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "ยกเลิก",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final reportText = reportController.text.trim();

              if (reportText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('กรุณากรอกเหตุผล'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              // บันทึก report ไป Firestore
              try {
                final deckId = widget.deckData?.id ?? '';
                if (deckId.isEmpty) return;

                await _firestore.collection('decks').doc(deckId).update({
                  'reports': FieldValue.arrayUnion([reportText]),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('รายงานเสร็จสิ้น ขอบคุณค่ะ'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('Error submitting report: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('มีข้อผิดพลาด: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String deckName = widget.deckData?['deck_name'] ?? "สำรับไพ่";
    final String deckImage =
        widget.deckData?['cover_image'] ??
        'https://picsum.photos/seed/deck/400/600';
    final String deckId = widget.deckData?.id ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleQuickDraw,
                    icon: Icon(
                      _isQuickDraw ? Icons.bolt : Icons.bolt_outlined,
                      color: _isQuickDraw ? Colors.yellowAccent : Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.new_releases_outlined, color: Colors.white),
                    onPressed: _showReportDialog,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              const Text(
                "กดที่ไพ่เพื่อเริ่มสุ่ม!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DrawResultPage(deckId: deckId, deckName: deckName),
                      ),
                    ),
                    behavior: HitTestBehavior.translucent,
                    child: Hero(
                      tag: 'deck_hero_$deckId',
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cosmicCyan.withOpacity(0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cosmicPurple.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: -5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(deckImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOutSine),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Text(
                deckName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              FutureBuilder<int>(
                future: _cardCountFuture,
                builder: (context, snapshot) {
                  final cardCount = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: AppColors.glassDecoration(radius: 20),
                    child: Text(
                      "จำนวนไพ่ในสำรับ : $cardCount ใบ",
                      style: const TextStyle(color: AppColors.cosmicCyan, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale();
                },
              ),
              const SizedBox(height: 40),
              const Column(
                children: [
                  Text(
                    "เลื่อนขึ้นเพื่อดูไพ่ในสำรับ",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white38),
                  SizedBox(height: 20),
                ],
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

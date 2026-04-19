import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import 'deck_view_wrapper.dart';



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Firebase reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ตัวแปรเก็บผลลัพธ์ที่กรองแล้ว
  List<QueryDocumentSnapshot> _filteredDecks = [];
  List<QueryDocumentSnapshot> _allVerifiedDecks = [];
  bool _isLoading = true; // เพิ่มตัวแปรสำหรับ loading state

  @override
  void initState() {
    super.initState();
    _fetchVerifiedDecks();
  }

  // ฟังก์ชันดึง Deck ที่ verified จาก Firebase
  Future<void> _fetchVerifiedDecks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('decks')
          .where('deck_status', isEqualTo: 'verified')
          .get();

      setState(() {
        _allVerifiedDecks = snapshot.docs;
        _filteredDecks = snapshot.docs;
        _isLoading = false; // เลิกโหลด
      });
    } catch (e) {
      print('Error fetching verified decks: $e');
      setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันสำหรับการค้นหา (Logic ที่คุณถาม)
  void _runFilter(String enteredKeyword) {
    List<QueryDocumentSnapshot> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allVerifiedDecks;
    } else {
      results = _allVerifiedDecks.where((deck) {
        final deckName = (deck['deck_name'] ?? '').toString().toLowerCase();
        final creatorUsername = (deck['creator_username'] ?? '').toString().toLowerCase();
        final keyword = enteredKeyword.toLowerCase();
        
        return deckName.contains(keyword) || creatorUsername.contains(keyword);
      }).toList();
    }

    setState(() {
      _filteredDecks = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ส่วน Search Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2140),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        onChanged: (value) => _runFilter(value), // ค้นหา Real-time
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          border: InputBorder.none,
                          hintText: "ค้นหาด้วยชื่อหรือผู้สร้าง...",
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. รายการ Deck (Grid View)
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.amber),
                          const SizedBox(height: 15),
                          const Text(
                            "กำลังโหลด Deck...",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : _filteredDecks.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // แสดง 3 คอลัมน์ตามรูป
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.7, // สัดส่วนแนวตั้งของไพ่
                          ),
                          itemCount: _filteredDecks.length,
                          itemBuilder: (context, index) {
                            return _buildDeckItem(_filteredDecks[index]);
                          },
                        )
                      : const Center(
                          child: Text("ไม่พบ Deck ที่คุณค้นหา", style: TextStyle(color: Colors.white38)),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับแต่ละใบใน Grid
  Widget _buildDeckItem(QueryDocumentSnapshot deck) {
    final String coverImage = deck['cover_image'] ?? 'สำรับไพ่';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DeckViewWrapper(),
            settings: RouteSettings(arguments: deck), // ส่งข้อมูล deck จาก Firebase
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // ใช้ FadeTransition (ค่อยๆ จางปรากฏ) + ScaleTransition (ค่อยๆ ขยาย)
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500), // ความเร็วในการเปิดหน้า
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: coverImage.isNotEmpty
              ? Image.network(
                  coverImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
                )
              : Container(
                  color: Colors.grey[800],
                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30)),
                ),
        ),
      ),
    );
  }
}
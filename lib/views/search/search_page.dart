import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'deck_view_wrapper.dart';



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  
  // --- Mock Data: รายการ Deck ใน Database ---
  final List<Map<String, String>> _allDecks = [
    {'name': 'Golden Sun', 'code': '1001', 'image': 'https://picsum.photos/seed/1/200/300'},
    {'name': 'Moonlight', 'code': '1002', 'image': 'https://picsum.photos/seed/2/200/300'},
    {'name': 'Cosmic Eye', 'code': '1003', 'image': 'https://picsum.photos/seed/3/200/300'},
    {'name': 'Galaxy Portal', 'code': '1004', 'image': 'https://picsum.photos/seed/4/200/300'},
    {'name': 'Starlight', 'code': '1005', 'image': 'https://picsum.photos/seed/5/200/300'},
    {'name': 'Eternity', 'code': '1006', 'image': 'https://picsum.photos/seed/6/200/300'},
  ];

  // ตัวแปรเก็บผลลัพธ์ที่กรองแล้ว
  List<Map<String, String>> _filteredDecks = [];

  @override
  void initState() {
    super.initState();
    _filteredDecks = _allDecks; // เริ่มต้นให้โชว์ทั้งหมด
  }

  // ฟังก์ชันสำหรับการค้นหา (Logic ที่คุณถาม)
  void _runFilter(String enteredKeyword) {
    List<Map<String, String>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allDecks;
    } else {
      results = _allDecks.where((deck) =>
          deck["name"]!.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          deck["code"]!.contains(enteredKeyword)).toList();
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
            // 1. ส่วน Search Bar ตามรูป
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
                          hintText: "ค้นหาด้วยชื่อ หรือ Code...",
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
              child: _filteredDecks.isNotEmpty
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
  Widget _buildDeckItem(Map<String, String> deck) {
    return GestureDetector(
      onTap: () {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const DeckViewWrapper(),
      settings: RouteSettings(arguments: deck), // ส่งข้อมูล deck ไปเหมือนเดิม
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
          child: Image.network(
            deck['image']!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
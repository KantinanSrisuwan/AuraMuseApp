import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../search/deck_view_wrapper.dart';

class MyDeckPage extends StatefulWidget {
  const MyDeckPage({super.key});

  @override
  State<MyDeckPage> createState() => _MyDeckPageState();
}

class _MyDeckPageState extends State<MyDeckPage> {
  // Mock ข้อมูลแยกตามหมวดหมู่
  final List<Map<String, String>> _myCreatedDecks = [
    {'name': 'สำรับที่ฉันสร้าง 1', 'image': 'https://picsum.photos/seed/m1/200/300'},
    {'name': 'สำรับที่ฉันสร้าง 2', 'image': 'https://picsum.photos/seed/m2/200/300'},
  ];

  final List<Map<String, String>> _favoriteDecks = [
    {'name': 'สำรับโปรด 1', 'image': 'https://picsum.photos/seed/f1/200/300'},
  ];

  @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      // 1. เอา AppBar ออกไปเลย
      body: SafeArea( 
        child: Column(
          children: [
            // 2. ส่วนของ TabBar ที่ย้ายมาไว้ใน Column แทนเพื่อให้ติดขอบบน
            const TabBar(
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.amber,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              // ลบ padding ส่วนเกินออก
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(text: "สำรับของฉัน"),
                Tab(text: "รายการโปรดของสำรับ"),
                Tab(text: "ควิกดรอว์"),
              ],
            ),
            
            // 3. ส่วนแสดงเนื้อหาของแต่ละ Tab
            Expanded(
              child: TabBarView(
                children: [
                  _buildDeckGrid(_myCreatedDecks, showAddButton: true),
                  _buildDeckGrid(_favoriteDecks),
                  _buildDeckGrid([]),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ฟังก์ชันสร้าง Grid แสดงผล Deck (เหมือนหน้า Search)
  Widget _buildDeckGrid(List<Map<String, String>> decks, {bool showAddButton = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.65,
      ),
      // ถ้าเป็นหน้า "สำรับของฉัน" ให้เพิ่มจำนวนไอเทมไปอีก 1 เพื่อวางปุ่ม +
      itemCount: showAddButton ? decks.length + 1 : decks.length,
      itemBuilder: (context, index) {
        // กรณีปุ่มเพิ่มสำรับใหม่ (+)
        if (showAddButton && index == decks.length) {
          return _buildAddButton();
        }

        final deck = decks[index];
        return GestureDetector(
          onTap: () {
            // ใช้ PageRouteBuilder ที่เราเพิ่งทำ เพื่อให้การวาร์ปไปหน้า Detail นุ่มนวล
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
            tag: 'deck_hero_${deck['name']}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(deck['image']!, fit: BoxFit.cover ,errorBuilder: (context, error, stackTrace) {
          return Container(
      color: Colors.white10,
      child: const Icon(Icons.broken_image, color: Colors.white24),
    );
  },loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(color: Colors.white.withOpacity(0.05));
  },
        ),
            ),
          ),
        );
      },
    );
  }

  // ปุ่มสร้างสำรับใหม่ (+)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => print("ไปหน้าสร้างสำรับใหม่"),
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
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'edit_deck_page.dart';

class ManageDeckPage extends StatelessWidget {
  const ManageDeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock ข้อมูล (ในอนาคตดึงจาก Local DB หรือ Firebase)
    final List<Map<String, String>> myDecks = [
      {'name': 'สำรับที่ 1', 'image': 'https://picsum.photos/seed/d1/200/300'},
      {'name': 'สำรับที่ 2', 'image': 'https://picsum.photos/seed/d2/200/300'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("จัดการสำรับของฉัน", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.65,
                ),
                itemCount: myDecks.length + 1,
                itemBuilder: (context, index) {
                  if (index == myDecks.length) return _buildAddBtn(context);
                  return _buildDeckItem(context, myDecks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditDeckPage())),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.add, color: Colors.white24, size: 40),
      ),
    );
  }

  Widget _buildDeckItem(BuildContext context, Map<String, String> deck) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditDeckPage(initialData: deck))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(deck['image']!, fit: BoxFit.cover),
      ),
    );
  }
}
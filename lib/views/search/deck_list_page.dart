import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/draw_result_page.dart';

class DeckListPage extends StatelessWidget {
  final Map<String, dynamic>? deckData;
  const DeckListPage({super.key, this.deckData});

  @override
  Widget build(BuildContext context) {
    final String deckName = deckData?['name'] ?? "สำรับไพ่";
    final List<String> mockCards = List.generate(15, (i) => 'https://picsum.photos/seed/c$i/200/300');

    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
          const Text("ปัดลงเพื่อกลับไปหน้าปก", style: TextStyle(color: Colors.white24, fontSize: 12)),
          const SizedBox(height: 20),
          Text(deckName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(), // เลื่อน Grid แบบนุ่มนวล
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              itemCount: mockCards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DrawResultPage(deckName: deckName)));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(mockCards[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:math';

class AdminVerifyDeckPage extends StatefulWidget {
  const AdminVerifyDeckPage({super.key});

  @override
  State<AdminVerifyDeckPage> createState() => _AdminVerifyDeckPageState();
}

class _AdminVerifyDeckPageState extends State<AdminVerifyDeckPage> {
  final PageController _pageController = PageController();

  // ฟังก์ชันแสดง Pop-up เมื่อกด อนุญาต/ไม่อนุญาต
  void _handleVerify(bool isAllow) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: isAllow ? Colors.green : Colors.orangeAccent),
        ),
        title: Text(
          isAllow ? "ยืนยันการอนุญาต" : "เหตุผลที่ไม่ได้รับอนุญาต", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: isAllow 
          ? const Text("เมื่อกดยืนยัน สำรับนี้จะถูกเผยแพร่สู่สาธารณะทันที", style: TextStyle(color: Colors.white70))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("กรุณาระบุเหตุผลเพื่อให้เจ้าของสำรับทราบ:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "เช่น เนื้อหาไม่เหมาะสม...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    fillColor: Colors.white.withOpacity(0.05),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.white30)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isAllow ? Colors.green : Colors.redAccent), 
            onPressed: () {
              // กลับไปหน้าบัญชีทั้งหมด (Pop 2 ครั้ง: ปิด Dialog และ ปิดหน้า Detail)
              Navigator.of(context)..pop()..pop(); 
            }, 
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    int count = int.tryParse(args['cardCount'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            children: [
              _buildVerifyInfo(args),
              _buildVerifyGrid(args, count),
            ],
          ),
          // ปุ่มกดด้านล่าง
          Positioned(
            bottom: 30, left: 20, right: 20, 
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ), 
                    onPressed: () => _handleVerify(true), 
                    child: const Text("อนุญาต", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, 
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ), 
                    onPressed: () => _handleVerify(false), 
                    child: const Text("ไม่อนุญาต", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyInfo(dynamic args) => SingleChildScrollView(
    padding: const EdgeInsets.all(20), 
    child: Column(
      children: [
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.centerLeft, 
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), 
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Container(
          width: double.infinity, 
          padding: const EdgeInsets.all(15), 
          color: const Color(0xFF6A4CFF), 
          child: Text(
            args['deckName'] ?? "สำรับรอตรวจสอบ", 
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Container(
              width: 150, height: 230, 
              decoration: BoxDecoration(
                color: Colors.white10, 
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white12),
              ), 
              child: const Icon(Icons.style, size: 80, color: Colors.white24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text("ID: ${args['deckId']}", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text("การ์ด: ${args['cardCount']} ใบ", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  const Text("สถานะ: รอตรวจสอบ", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 50),
        const Text("สถิติการใช้งาน", style: TextStyle(color: Colors.white24)),
        const SizedBox(height: 15),
        Container(
          height: 140, width: 140, 
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle), 
          child: const Center(child: Text("ไม่มีสถิติ", style: TextStyle(color: Colors.white24))),
        ),
        const SizedBox(height: 60),
        const Text("ปัดขึ้นเพื่อดูไพ่ในสำรับ ↑", style: TextStyle(color: Colors.white12, fontSize: 12)),
        const SizedBox(height: 120),
      ],
    ),
  );

  Widget _buildVerifyGrid(dynamic args, int count) => Column(
    children: [
      const SizedBox(height: 60),
      Text("รายการไพ่: ${args['deckName']}", style: const TextStyle(color: Colors.white, fontSize: 18)),
      const SizedBox(height: 20),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20), 
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12,
          ), 
          itemCount: count, 
          itemBuilder: (c, i) => GestureDetector(
            onTap: () {
              // ลบ const ออกจากตรงนี้เพื่อป้องกัน error
              Navigator.push(context, MaterialPageRoute(builder: (c) => CardFlipView()));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05), 
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
              ), 
              child: const Icon(Icons.style, color: Colors.orangeAccent, size: 35),
            ),
          ),
        ),
      ),
      const SizedBox(height: 110),
    ],
  );
}

// --- หน้าพลิกไพ่ 3D (คลาสที่หายไป) ---
class CardFlipView extends StatefulWidget {
  const CardFlipView({super.key});

  @override
  State<CardFlipView> createState() => _CardFlipViewState();
}

class _CardFlipViewState extends State<CardFlipView> {
  bool isFront = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E20),
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () => setState(() => isFront = !isFront),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: isFront ? 0 : pi),
                builder: (context, double value, child) => Transform(
                  transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(value),
                  alignment: Alignment.center,
                  child: value < pi / 2 
                      ? _cardSide(Icons.wb_sunny, "รูปภาพไพ่ (ด้านหน้า)") 
                      : Transform(
                          transform: Matrix4.rotationY(pi), 
                          alignment: Alignment.center, 
                          child: _cardSide(Icons.menu_book, "บทกวีหรือคำทำนาย"),
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50, left: 20, 
            child: Container(
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), 
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), 
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSide(IconData icon, String text) => Container(
    width: 280, height: 450, 
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E), 
      borderRadius: BorderRadius.circular(20), 
      border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3),
    ), 
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Icon(icon, size: 100, color: Colors.orangeAccent), 
        const SizedBox(height: 30), 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20), 
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)),
        ),
      ],
    ),
  );
}
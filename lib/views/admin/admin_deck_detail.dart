import 'package:flutter/material.dart';
import 'dart:math';

// ==========================================================
// 1. หน้าหลัก (Controller) - คุมการสลับระหว่าง "ไฟล์ข้อมูล" และ "ไฟล์รายการไพ่"
// ==========================================================
class AdminDeckDetailPage extends StatefulWidget {
  const AdminDeckDetailPage({super.key});
  @override State<AdminDeckDetailPage> createState() => _AdminDeckDetailPageState();
}

class _AdminDeckDetailPageState extends State<AdminDeckDetailPage> {
  final PageController _pageController = PageController();

  // ฟังก์ชันสลับหน้าไฟล์
  void _jumpToPage(int page) {
    _pageController.animateToPage(
      page, 
      duration: const Duration(milliseconds: 600), 
      curve: Curves.easeInOutQuart
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    bool isPublic = args['isPublic'] ?? false;
    String status = args['status'] ?? "ไม่ระบุ";

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: Stack(
        children: [
          // Mechanic: เปลี่ยนหน้าแบบพลิกไฟล์ (ลื่นและลากง่าย)
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            children: [
              // --- ไฟล์ที่ 1: รายละเอียดสำรับ ---
              DeckInfoPart(args: args, isPublic: isPublic, status: status, onNext: () => _jumpToPage(1)),
              // --- ไฟล์ที่ 2: รายการไพ่ในสำรับ ---
              DeckGridPart(args: args, onBack: () => _jumpToPage(0)),
            ],
          ),
          // ปุ่ม Action ลอยคงที่ (เฉพาะของหน้า Deck)
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  // --- ส่วนปุ่มกดยันยืนการลบ (ดีไซน์เดิมของหน้า Deck) ---
  Widget _buildBottomButtons(BuildContext context) => Positioned(
    bottom: 30, left: 20, right: 20,
    child: Row(children: [
      Expanded(child: _actionButton("ลบสำรับทิ้ง", Colors.redAccent, () => _showDeleteDialog(context))),
    ]),
  );

  Widget _actionButton(String text, Color color, VoidCallback onPressed) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color, 
      padding: const EdgeInsets.symmetric(vertical: 18), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
    ),
    onPressed: onPressed,
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
  );

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: const Text("คำเตือน!!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("การลบข้อมูลนี้เป็นการลบข้อมูลของสำรับถาวร ยืนยันที่จะลบหรือไม่", style: TextStyle(color: Colors.white70)),
        actions: [
          Row(children: [
            Expanded(child: _actionButton("ยืนยัน", Colors.redAccent, () => Navigator.of(context)..pop()..pop("delete"))),
            const SizedBox(width: 10),
            Expanded(child: _actionButton("ยกเลิก", const Color(0xFF455A64), () => Navigator.pop(context))),
          ]),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }
}

// ==========================================================
// 2. ไฟล์หน้าข้อมูลสำรับ (DeckInfoPart)
// ==========================================================
class DeckInfoPart extends StatelessWidget {
  final Map<String, dynamic> args;
  final bool isPublic;
  final String status;
  final VoidCallback onNext;
  
  const DeckInfoPart({
    super.key, 
    required this.args, 
    required this.isPublic, 
    required this.status, 
    required this.onNext
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // ถ้าไถจนสุดเนื้อหาสถิติแล้ว ให้สั่งเปลี่ยนหน้าไป Grid
        if (notification is ScrollUpdateNotification && notification.metrics.pixels >= notification.metrics.maxScrollExtent && notification.scrollDelta! > 5) {
          onNext();
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 10), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)))),
            
            // ✅ แถบชื่อสำรับสีม่วง (ยาวสุดขอบจอเหมือนเดิม)
            Container(
              width: double.infinity, 
              padding: const EdgeInsets.symmetric(vertical: 18), 
              margin: const EdgeInsets.symmetric(vertical: 10), 
              color: const Color(0xFF6A4CFF), 
              child: Text(
                args['deckName'] ?? "ชื่อสำรับ", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
              )
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // รูปปกสำรับ
                      Container(width: 160, height: 250, decoration: BoxDecoration(color: const Color(0xFF4A3AFF), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))), child: const Icon(Icons.style, size: 90, color: Colors.white24)),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 20),
                        _infoRow("หมายเลขเด็ค", args['deckId'] ?? "-"),
                        _infoRow("จำนวนการ์ด", "${args['cardCount']} ใบ"),
                        _infoRow("ผู้สร้าง", "ราชาคนุษยัยามดึก"),
                        const SizedBox(height: 15),
                        Text("สถานะ : $status", style: TextStyle(color: status == "เผยแพร่แล้ว" ? Colors.greenAccent : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
                      ])),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Text("สถิติการเข้าชมและสุ่มไพ่", style: TextStyle(color: Colors.white60, fontSize: 16)),
                  const SizedBox(height: 25),
                  
                  // แสดงวงกลมสถิติตามเงื่อนไขเดิม
                  isPublic 
                    ? const Center(child: CircleAvatar(radius: 70, backgroundColor: Colors.orangeAccent)) 
                    : Container(height: 140, width: 140, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Center(child: Text("ไม่มีข้อมูล\n(สำรับส่วนตัว)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 12)))),
                  
                  const SizedBox(height: 60),
                  const Text("ไถขึ้นเพื่อดูไพ่ในสำรับ ↑", style: TextStyle(color: Colors.white24, fontSize: 12)),
                  
                  // ✅ แก้ปัญหาตัวอักษรจมหลังปุ่ม
                  const SizedBox(height: 250), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text("$title : $value", style: const TextStyle(color: Colors.white70, fontSize: 15)));
}

// ==========================================================
// 3. ไฟล์หน้ารายการไพ่ (DeckGridPart)
// ==========================================================
class DeckGridPart extends StatelessWidget {
  final Map<String, dynamic> args;
  final VoidCallback onBack;
  const DeckGridPart({super.key, required this.args, required this.onBack});

  @override
  Widget build(BuildContext context) {
    int cardCount = int.tryParse(args['cardCount'].toString()) ?? 0;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // ถ้าไถลงจนสุดขอบบนแล้ว ให้สั่งกลับหน้าข้อมูล
        if (notification is ScrollUpdateNotification && notification.metrics.pixels <= 0 && notification.scrollDelta! < -5) {
          onBack();
        }
        return false;
      },
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(args['deckName'] ?? "สำรับ", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("$cardCount ใบ", style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Divider(color: Colors.white24, indent: 20, endIndent: 20, height: 30),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: cardCount,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CardFlipView())),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), 
                    borderRadius: BorderRadius.circular(8), 
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
                  ), 
                  child: const Icon(Icons.style, color: Colors.orangeAccent, size: 40)
                ),
              ),
            ),
          ),
          const Text("ไถลงเพื่อกลับ ↓", style: TextStyle(color: Colors.white24, fontSize: 12)),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

// ==========================================================
// 4. หน้าพลิกไพ่ 3D (แชร์ฟังก์ชันร่วมกัน)
// ==========================================================
class CardFlipView extends StatefulWidget {
  const CardFlipView({super.key});
  @override State<CardFlipView> createState() => _CardFlipViewState();
}
class _CardFlipViewState extends State<CardFlipView> {
  bool isFront = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E20),
      body: SafeArea(
        child: Stack(
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
                        : Transform(transform: Matrix4.rotationY(pi), alignment: Alignment.center, child: _cardSide(Icons.menu_book, "บทกวีหรือคำทำนาย")),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10, left: 10, 
              child: Container(
                decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), 
                child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))
              )
            ),
          ],
        ),
      ),
    );
  }
  Widget _cardSide(IconData icon, String text) => Container(
    width: 280, height: 450, 
    decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3)), 
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 100, color: Colors.orangeAccent), const SizedBox(height: 30), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)))])
  );
}
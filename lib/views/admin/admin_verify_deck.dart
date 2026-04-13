import 'package:flutter/material.dart';
import 'dart:math';

// ==========================================================
// 1. หน้าหลัก (Controller)
// ==========================================================
class AdminVerifyDeckPage extends StatefulWidget {
  const AdminVerifyDeckPage({super.key});
  @override State<AdminVerifyDeckPage> createState() => _AdminVerifyDeckPageState();
}

class _AdminVerifyDeckPageState extends State<AdminVerifyDeckPage> {
  final PageController _pageController = PageController();

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
    int count = int.parse(args['cardCount'].toString());

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            children: [
              VerifyInfoPart(args: args, onNext: () => _jumpToPage(1)),
              VerifyGridPart(args: args, count: count, onBack: () => _jumpToPage(0)),
            ],
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) => Positioned(
    bottom: 30, left: 20, right: 20,
    child: Row(children: [
      Expanded(child: _actionButton("อนุญาต", Colors.green, () => _handleVerify(true))),
      const SizedBox(width: 15),
      Expanded(child: _actionButton("ไม่อนุญาต", Colors.redAccent, () => _handleVerify(false))),
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

  void _handleVerify(bool isAllow) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), 
          side: const BorderSide(color: Colors.orangeAccent, width: 2)
        ),
        title: Text(
          isAllow ? "ยืนยันการอนุญาต" : "เหตุผลที่ไม่ได้รับอนุญาต", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                  )
                ),
              ]
            ),
        actions: [
          Row(children: [
            Expanded(child: _actionButton("ยืนยัน", isAllow ? Colors.green : Colors.redAccent, () => Navigator.of(context)..pop()..pop())),
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
// 2. ไฟล์หน้าข้อมูล (VerifyInfoPart)
// ==========================================================
class VerifyInfoPart extends StatelessWidget {
  final dynamic args;
  final VoidCallback onNext;
  const VerifyInfoPart({super.key, required this.args, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
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
            
            Container(
              width: double.infinity, 
              padding: const EdgeInsets.symmetric(vertical: 18), 
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: const Color(0xFF6A4CFF), 
              child: Text(
                args['deckName'] ?? "สำรับรอตรวจสอบ", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 150, height: 230, 
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)), 
                        child: const Icon(Icons.style, size: 80, color: Colors.white24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Text("ID: ${args['deckId']}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 12),
                            Text("การ์ด: ${args['cardCount']} ใบ", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 12),
                            const Text("สถานะ : รอตรวจสอบ", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                          ]
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Text("สถิติการใช้งาน", style: TextStyle(color: Colors.white24)),
                  const SizedBox(height: 20),
                  Container(
                    height: 140, width: 140, 
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle), 
                    child: const Center(child: Text("ไม่มีสถิติ", style: TextStyle(color: Colors.white24))),
                  ),
                  const SizedBox(height: 60),
                  const Text("ไถขึ้นเพื่อดูไพ่ในสำรับ ↑", style: TextStyle(color: Colors.white12, fontSize: 12)),
                  const SizedBox(height: 250), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 3. ไฟล์หน้ารายการไพ่ (VerifyGridPart) - แก้ไขส่วนหัวข้อที่หายไป
// ==========================================================
class VerifyGridPart extends StatelessWidget {
  final dynamic args;
  final int count;
  final VoidCallback onBack;
  const VerifyGridPart({super.key, required this.args, required this.count, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && notification.metrics.pixels <= 0 && notification.scrollDelta! < -5) {
          onBack();
        }
        return false;
      },
      child: Column(
        children: [
          const SizedBox(height: 60),
          
          // ✅ ✅ ✅ คืนค่าหัวข้อ: ชื่อสำรับ (ซ้าย) และ จำนวนใบ (ขวา) ตามรูป
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  args['deckName'] ?? "ชื่อสำรับ", 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                ),
                Text(
                  "${args['cardCount']} ใบ", 
                  style: const TextStyle(color: Colors.white70, fontSize: 16)
                ),
              ],
            ),
          ),
          
          // เส้น Divider ใต้หัวข้อ
          const Divider(color: Colors.white24, indent: 20, endIndent: 20, height: 30),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20), 
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12
              ), 
              itemCount: count, 
              itemBuilder: (c, i) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CardFlipView())), 
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10, 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
                  ), 
                  child: const Icon(Icons.style, color: Colors.orangeAccent)
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

// (หน้า CardFlipView คงเดิม)
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
                    ? _side(Icons.wb_sunny, "รูปภาพไพ่ (ด้านหน้า)") 
                    : Transform(transform: Matrix4.rotationY(pi), alignment: Alignment.center, child: _side(Icons.menu_book, "บทกวีหรือคำทำนาย")),
                ),
              ),
            ),
          ),
          Positioned(top: 50, left: 20, child: Container(decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)))),
        ],
      ),
    );
  }
  Widget _side(IconData i, String t) => Container(width: 280, height: 450, decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 100, color: Colors.orangeAccent), const SizedBox(height: 30), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(t, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)))]));
}
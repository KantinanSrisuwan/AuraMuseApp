import 'package:flutter/material.dart';
import 'dart:math';

// ==========================================================
// 1. หน้าหลัก (Controller) - คุมการเปลี่ยนไฟล์หน้า 1 และ 2
// ==========================================================
class AdminReportDetailPage extends StatefulWidget {
  const AdminReportDetailPage({super.key});
  @override State<AdminReportDetailPage> createState() => _AdminReportDetailPageState();
}

class _AdminReportDetailPageState extends State<AdminReportDetailPage> {
  final PageController _pageController = PageController();

  void _jumpToPage(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            children: [
              ReportInfoPart(args: args, onNext: () => _jumpToPage(1)),
              ReportGridPart(args: args, onBack: () => _jumpToPage(0)),
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
      Expanded(child: _btn("ลบสำรับทิ้ง", Colors.redAccent, () => _showDeleteDialog(context))),
      const SizedBox(width: 15),
      Expanded(child: _btn("ปฏิเสธการรายงาน", const Color(0xFF455A64), () => _showRejectDialog(context))),
    ]),
  );

  Widget _btn(String t, Color c, VoidCallback f) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: c, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: f, child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)));

  void _showDeleteDialog(BuildContext context) {
    _showAuraDialog(context, "คำเตือน!!", "การลบข้อมูลนี้เป็นการลบข้อมูลของสำรับถาวร ยืนยันที่จะลบหรือไม่", Colors.redAccent);
  }

  // ✅ ✅ ✅ คืนค่า: รายการเหตุผลที่ปฏิเสธ (Checkbox List)
  void _showRejectDialog(BuildContext context) {
    List<String> reasons = ["เป็นการรายงานเพื่อกลั่นแกล้ง", "เนื้อหาไม่ได้ละเมิดกฎการใช้งาน", "หลักฐานการรายงานไม่เพียงพอ", "ข้อมูลไม่เป็นความจริง"];
    List<bool> isChecked = [false, false, false, false];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
          title: Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
            child: const Text("เหตุผลที่ปฏิเสธ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(reasons.length, (index) => CheckboxListTile(
              title: Text(reasons[index], style: const TextStyle(color: Colors.white70, fontSize: 14)),
              value: isChecked[index],
              activeColor: Colors.orangeAccent,
              onChanged: (val) => setDialogState(() => isChecked[index] = val!),
              controlAffinity: ListTileControlAffinity.leading,
            )),
          ),
          actions: [
            Row(children: [
              Expanded(child: _btn("ยืนยัน", const Color(0xFF4A3AFF), () => Navigator.of(context)..pop()..pop())),
              const SizedBox(width: 10),
              Expanded(child: _btn("ยกเลิก", Colors.blueGrey[700]!, () => Navigator.pop(context))),
            ]),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        ),
      ),
    );
  }

  void _showAuraDialog(BuildContext context, String title, String content, Color confirmColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          Row(children: [
            Expanded(child: _btn("ยืนยัน", confirmColor, () => Navigator.of(context)..pop()..pop())),
            const SizedBox(width: 10),
            Expanded(child: _btn("ยกเลิก", Colors.blueGrey, () => Navigator.pop(context))),
          ]),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }
}

// ==========================================================
// 2. ไฟล์หน้าข้อมูล (ReportInfoPart)
// ==========================================================
class ReportInfoPart extends StatelessWidget {
  final dynamic args;
  final VoidCallback onNext;
  const ReportInfoPart({super.key, required this.args, required this.onNext});

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
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18), margin: const EdgeInsets.symmetric(vertical: 10), color: const Color(0xFF6A4CFF), child: Text(args['deckName'] ?? "สำรับ", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 160, height: 250, decoration: BoxDecoration(color: const Color(0xFF4A3AFF), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, 8))]), child: const Icon(Icons.style, size: 90, color: Colors.white24)),
                    const SizedBox(width: 20),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 20), Text("ID: ${args['deckId']}", style: const TextStyle(color: Colors.white70)), Text("จำนวน: ${args['cardCount']} ใบ", style: const TextStyle(color: Colors.white70)), const SizedBox(height: 15), const Text("สถานะ : เผยแพร่", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18))])),
                  ]),
                  const SizedBox(height: 35),
                  Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("ข้อความการรายงาน:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 10), Text(args['description'] ?? "-", style: const TextStyle(color: Colors.white, height: 1.5))])),
                  const SizedBox(height: 40),
                  const Center(child: CircleAvatar(radius: 65, backgroundColor: Colors.orangeAccent)),
                  const SizedBox(height: 60),
                  const Text("ไถขึ้นเพื่อสลับไปไฟล์รายการไพ่ ↑", style: TextStyle(color: Colors.white24, fontSize: 12)),
                  const SizedBox(height: 250), // แก้ปัญหาตัวอักษรจม
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
// 3. ไฟล์หน้ารายการไพ่ (ReportGridPart)
// ==========================================================
class ReportGridPart extends StatelessWidget {
  final dynamic args;
  final VoidCallback onBack;
  const ReportGridPart({super.key, required this.args, required this.onBack});

  @override
  Widget build(BuildContext context) {
    int cardCount = int.tryParse(args['cardCount'].toString()) ?? 0;
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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(args['deckName'] ?? "รายการไพ่", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text("$cardCount ใบ", style: const TextStyle(color: Colors.white70))])),
          const Divider(color: Colors.white24, indent: 20, endIndent: 20, height: 30),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: cardCount,
              itemBuilder: (context, index) => GestureDetector(
                // ✅ ✅ ✅ คืนค่า: กดดูไพ่ และพลิกได้เหมือนเดิม
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CardFlipView())),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), 
                    borderRadius: BorderRadius.circular(8), 
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
                  ), 
                  child: const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
                ),
              ),
            ),
          ),
          const Text("ไถลงเพื่อกลับ ↓", style: TextStyle(color: Colors.white24, fontSize: 12)),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ==========================================================
// 4. หน้าพลิกไพ่ 3D (CardFlipView) - คืนชีพฟีเจอร์เดิมครบชุด
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
            // ✅ ✅ ✅ คืนค่า: ปุ่มย้อนกลับ
            Positioned(
              top: 10, left: 10, 
              child: Container(
                decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), 
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), 
                  onPressed: () => Navigator.pop(context)
                )
              )
            ),
          ],
        ),
      ),
    );
  }
  Widget _cardSide(IconData icon, String text) => Container(
    width: 280, height: 450, 
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E), 
      borderRadius: BorderRadius.circular(20), 
      border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3)
    ), 
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Icon(icon, size: 100, color: Colors.orangeAccent), 
        const SizedBox(height: 30), 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20), 
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6))
        )
      ],
    )
  );
}
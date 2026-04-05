import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';

// --- 1. กฎการเลื่อนแบบ "ห้ามถอยหลังข้ามหน้า" ---
class StrictOneWayPhysics extends ScrollPhysics {
  const StrictOneWayPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  StrictOneWayPhysics applyTo(ScrollPhysics? ancestor) {
    return StrictOneWayPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    double pageHeight = position.viewportDimension;
    double currentPageStart = (position.pixels / pageHeight).floor() * pageHeight;
    // บล็อกไม่ให้เลื่อนย้อนกลับไปหน้าก่อนหน้า (ห้าม pixels น้อยกว่าจุดเริ่มหน้าปัจจุบัน)
    if (value < currentPageStart) {
      return value - currentPageStart;
    }
    return 0.0;
  }
}

class AdminReportDetailPage extends StatefulWidget {
  const AdminReportDetailPage({super.key});

  @override
  State<AdminReportDetailPage> createState() => _AdminReportDetailPageState();
}

class _AdminReportDetailPageState extends State<AdminReportDetailPage> {
  final PageController _pageController = PageController(initialPage: 1000);
  final ScrollController _gridScrollController = ScrollController();
  bool _isAnimating = false;
  bool _showScrollHint = false; // ตัวแปรคุมการแสดงข้อความท้ายหน้าไพ่

  @override
  void initState() {
    super.initState();
    // ดักจับการเลื่อนของหน้าไพ่
    _gridScrollController.addListener(() {
      if (_gridScrollController.hasClients) {
        // ถ้าเลื่อนมาจนเกือบถึงใบสุดท้าย (ห่างไม่เกิน 20 พิกเซล)
        bool atBottom = _gridScrollController.position.pixels >= 
                        _gridScrollController.position.maxScrollExtent - 20;
        if (atBottom != _showScrollHint) {
          setState(() => _showScrollHint = atBottom);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลื่อนหน้า
  void _goToPage(int page) {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    ).then((_) => setState(() => _isAnimating = false));
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: Stack(
        children: [
          // ส่วนเนื้อหาหลักที่ปัดขึ้นได้
          Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent && !_isAnimating) {
                if (pointerSignal.scrollDelta.dy > 0) {
                  bool isGridPage = _pageController.page!.toInt() % 2 != 0;
                  if (isGridPage) {
                    // ในหน้าไพ่: ต้องรูดไพ่ให้สุดก่อนถึงจะเปลี่ยนหน้าได้
                    if (_gridScrollController.position.pixels >= _gridScrollController.position.maxScrollExtent) {
                      _goToPage(_pageController.page!.toInt() + 1);
                    }
                  } else {
                    _goToPage(_pageController.page!.toInt() + 1);
                  }
                }
              }
            },
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const StrictOneWayPhysics(parent: PageScrollPhysics()),
              itemBuilder: (context, index) {
                if (index % 2 == 0) {
                  return _buildReportDetailView(context, args);
                } else {
                  return _buildDeckCardsGridView(context, args);
                }
              },
              onPageChanged: (index) {
                // รีเซ็ตหน้าไพ่ไปบนสุดเมื่อออกจากหน้า
                if (_gridScrollController.hasClients) {
                  _gridScrollController.jumpTo(0);
                }
              },
            ),
          ),
          // ปุ่ม Action ด้านล่าง (ลอยคงที่)
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  // --- หน้าที่ 1: รายละเอียด Report ---
  Widget _buildReportDetailView(BuildContext context, dynamic args) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF6A4CFF), borderRadius: BorderRadius.circular(5)),
                child: Text(args['deckName'] ?? "ชื่อสำรับ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Container(
                  width: 130, height: 200,
                  decoration: BoxDecoration(color: const Color(0xFF4A3AFF), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2)),
                  child: const Icon(Icons.style, size: 70, color: Colors.white24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoText("หมายเลขเด็ค", args['deckId'] ?? "-"),
                      _infoText("จำนวนการ์ด", "${args['cardCount']} ใบ"),
                      _infoText("ผู้สร้าง", "TOK TIK"),
                      const Text("สถานะ : เผยแพร่", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
              child: Text(args['description'] ?? "ไม่มีรายละเอียด", style: const TextStyle(color: Colors.white, height: 1.4)),
            ),
            const Spacer(),
            const Center(child: Text("สถิติการเข้าชมและสุ่มไพ่", style: TextStyle(color: Colors.white60))),
            const SizedBox(height: 20),
            const Center(child: CircleAvatar(radius: 60, backgroundColor: Colors.orangeAccent)),
            const SizedBox(height: 40),
            const Center(child: Text("เลื่อนขึ้นเพื่อดูไพ่ในสำรับ ↑", style: TextStyle(color: Colors.white30, fontSize: 12))),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // --- หน้าที่ 2: รายการไพ่ (เลื่อนดูได้ 15 ใบ) ---
  Widget _buildDeckCardsGridView(BuildContext context, dynamic args) {
    int cardCount = int.tryParse(args['cardCount'].toString()) ?? 0;
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(args['deckName'] ?? "สำรับ", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text("$cardCount ใบ", style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // สำหรับ Touch: ถ้าไถจนสุดก้นแล้ว และไถขึ้นแรงๆ ให้เปลี่ยนหน้า
                if (notification is ScrollUpdateNotification && 
                    _gridScrollController.position.pixels >= _gridScrollController.position.maxScrollExtent &&
                    notification.scrollDelta! > 10) {
                  _goToPage(_pageController.page!.toInt() + 1);
                }
                return false;
              },
              child: GridView.builder(
                controller: _gridScrollController,
                physics: const ClampingScrollPhysics(), // ยอมให้เลื่อนภายในตัวมันเอง
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12
                ),
                itemCount: cardCount,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _showCardFlipDetail(context),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))),
                    child: const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
                  ),
                ),
              ),
            ),
          ),
          // ข้อความ Hint ที่จะโผล่เฉพาะตอนรูดมาถึงใบสุดท้าย
          AnimatedOpacity(
            opacity: _showScrollHint ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text("เลื่อนไพ่ให้สุดแล้วปัดขึ้นเพื่อเปลี่ยนหน้า ↑", style: TextStyle(color: Colors.white30, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  // --- ฟังก์ชันเสริมต่างๆ ---

  Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text("$title : $value", style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Positioned(
      bottom: 30, left: 20, right: 20,
      child: Row(
        children: [
          Expanded(child: _actionButton("ลบสำรับทิ้ง", Colors.redAccent, () => _showDeleteDialog(context))),
          const SizedBox(width: 15),
          Expanded(child: _actionButton("ปฏิเสธการรายงาน", Colors.blueGrey[800]!, () => _showRejectDialog(context))),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  // --- Dialog ลบสำรับ (สไตล์ระเบียบ โทนสำรับ) ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text("คำเตือน!!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        content: const Text("การลบข้อมูลนี้เป็นการลบข้อมูลของสำรับถาวร ยืนยันที่จะลบสำรับทิ้งหรือไม่", style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
        actions: [
          Row(
            children: [
              Expanded(child: _actionButton("ยืนยัน", Colors.redAccent, () => Navigator.of(context)..pop()..pop())),
              const SizedBox(width: 10),
              Expanded(child: _actionButton("ยกเลิก", Colors.blueGrey[700]!, () => Navigator.pop(context))),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  // --- Dialog ปฏิเสธรายงาน (สไตล์ระเบียบ โทนสำรับ) ---
  void _showRejectDialog(BuildContext context) {
    List<String> reasons = ["เป็นการรายงานเพื่อกลั่นแกล้ง", "เนื้อหาไม่ได้ละเมิดกฎการใช้งาน", "หลักฐานการรายงานไม่เพียงพอ", "ข้อมูลที่รายงานมาไม่เป็นความจริง"];
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
              checkColor: Colors.black,
              onChanged: (val) => setDialogState(() => isChecked[index] = val!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            )),
          ),
          actions: [
            Row(
              children: [
                Expanded(child: _actionButton("ยืนยัน", const Color(0xFF4A3AFF), () => Navigator.of(context)..pop()..pop())),
                const SizedBox(width: 10),
                Expanded(child: _actionButton("ยกเลิก", Colors.blueGrey[700]!, () => Navigator.pop(context))),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        ),
      ),
    );
  }

  void _showCardFlipDetail(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CardFlipView()));
  }
}

// --- หน้าพลิกไพ่ 3D ---
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
                  builder: (context, double value, child) {
                    return Transform(
                      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(value),
                      alignment: Alignment.center,
                      child: value < pi / 2 
                        ? _cardSide(Icons.wb_sunny, "รูปภาพไพ่ (ด้านหน้า)") 
                        : Transform(transform: Matrix4.rotationY(pi), alignment: Alignment.center, child: _cardSide(Icons.menu_book, "บทกวีหรือคำทำนาย\n(ด้านหลัง)")),
                    );
                  },
                ),
              ),
            ),
            Positioned(top: 10, left: 10, child: Container(decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)))),
          ],
        ),
      ),
    );
  }
  Widget _cardSide(IconData icon, String text) => Container(width: 280, height: 450, decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3), boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.1), blurRadius: 15)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 100, color: Colors.orangeAccent), const SizedBox(height: 30), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)))],));
}
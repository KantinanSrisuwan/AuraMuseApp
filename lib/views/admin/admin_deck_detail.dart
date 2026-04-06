import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';
import 'dart:ui';

// --- 1. กฎการเลื่อนแบบ "ห้ามถอยหลังข้ามหน้า" ---
// ส่วนนี้สำคัญมากสำหรับการทำให้ PageView แบบ Vertical นิ่งและไม่กระตุกกลับ
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
    if (value < currentPageStart) {
      return value - currentPageStart;
    }
    return 0.0;
  }
}

// --- 2. การตั้งค่าเพื่อให้เมาส์สามารถ "คลิกลาก" ได้เหมือนมือถือ ---
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // เปิดให้เมาส์ลากได้
        PointerDeviceKind.trackpad,
      };
}

class AdminDeckDetailPage extends StatefulWidget {
  const AdminDeckDetailPage({super.key});

  @override
  State<AdminDeckDetailPage> createState() => _AdminDeckDetailPageState();
}

class _AdminDeckDetailPageState extends State<AdminDeckDetailPage> {
  // หน้า 0: ข้อมูลสำรับ, หน้า 1: รายการไพ่
  final PageController _pageController = PageController(initialPage: 0);
  final ScrollController _infoScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();
  
  bool _isAnimating = false;

  @override
  void dispose() {
    _pageController.dispose();
    _infoScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลื่อนหน้าแบบ Smooth
  void _goToPage(int page) {
    if (_isAnimating || page < 0 || page > 1) return;
    setState(() => _isAnimating = true);
    _pageController
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        )
        .then((_) => setState(() => _isAnimating = false));
  }

  @override
  Widget build(BuildContext context) {
    // รับข้อมูล Arguments จากการกดมา
    final dynamic rawArgs = ModalRoute.of(context)!.settings.arguments;
    final Map<String, dynamic> args = (rawArgs is Map<String, dynamic>) ? rawArgs : {};
    
    // ดึงสถานะมาเช็ก Logic กราฟและสี
    bool isPublic = args['isPublic'] ?? false;
    String status = args['status'] ?? "ไม่ระบุ";

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: Stack(
          children: [
            // ส่วน Listener สำหรับเปลี่ยนหน้าด้วยลูกกลิ้งเมาส์ (Mouse Wheel)
            Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent && !_isAnimating) {
                  // หมุนลง -> ไปหน้าไพ่ (หน้า 1)
                  if (pointerSignal.scrollDelta.dy > 10 && _pageController.page == 0) {
                    if (_infoScrollController.position.pixels >= _infoScrollController.position.maxScrollExtent) {
                      _goToPage(1);
                    }
                  } 
                  // หมุนขึ้น -> กลับหน้าข้อมูล (หน้า 0)
                  else if (pointerSignal.scrollDelta.dy < -10 && _pageController.page == 1) {
                    if (_gridScrollController.position.pixels <= 0) {
                      _goToPage(0);
                    }
                  }
                }
              },
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(), // ใช้ Logic ของเราคุมเอง 100%
                children: [
                  _buildDeckInfoView(context, args, isPublic, status), // หน้า 0
                  _buildDeckCardsGridView(context, args),             // หน้า 1
                ],
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  // --- หน้าที่ 1: รายละเอียดสำรับ ---
  Widget _buildDeckInfoView(BuildContext context, Map<String, dynamic> args, bool isPublic, String status) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && !_isAnimating) {
          // Logic: ถ้าไถลงจนสุดขอบล่างแล้วไถต่อ -> สั่ง PageView เปลี่ยนหน้า
          if (_infoScrollController.position.pixels >= _infoScrollController.position.maxScrollExtent &&
              notification.scrollDelta! > 8) {
            _goToPage(1);
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _infoScrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // แถบหัวข้อสีม่วงยาวเต็มจอ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: const Color(0xFF6A4CFF),
              child: Text(
                args['deckName'] ?? "ชื่อสำรับ",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // รูปปกสำรับขนาดใหญ่ (160x250)
                      Container(
                        width: 160, height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3AFF),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: const Icon(Icons.style, size: 90, color: Colors.white24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _infoRow("หมายเลขเด็ค", args['deckId'] ?? "-"),
                            _infoRow("จำนวนการ์ด", "${args['cardCount']} ใบ"),
                            _infoRow("ผู้สร้าง", "ราชาคนุษยัยามดึก"),
                            _infoRow("วันที่สร้าง", "08/03/2026"),
                            const SizedBox(height: 15),
                            Text(
                              "สถานะ : $status", 
                              style: TextStyle(
                                color: status == "เผยแพร่แล้ว" ? Colors.greenAccent : Colors.orangeAccent, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 18
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Text("สถิติการเข้าชมและสุ่มไพ่", style: TextStyle(color: Colors.white60, fontSize: 16)),
                  const SizedBox(height: 25),
                  
                  // Logic แสดงกราฟ: ถ้าเป็นสำรับสาธารณะถึงจะโชว์ ข้อมูลส่วนตัว/รอตรวจ จะแสดงวงกลมว่าง
                  isPublic 
                    ? const Center(child: CircleAvatar(radius: 70, backgroundColor: Colors.orangeAccent))
                    : Container(
                        height: 140, width: 140,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                        child: const Center(
                          child: Text("ไม่มีข้อมูล\n(สำรับส่วนตัว)", 
                            textAlign: TextAlign.center, 
                            style: TextStyle(color: Colors.white24, fontSize: 12)
                          )
                        ),
                      ),
                  
                  const SizedBox(height: 60),
                  const Text("ปัดขึ้นเพื่อดูไพ่ในสำรับ ↑", style: TextStyle(color: Colors.white30, fontSize: 12)),
                  const SizedBox(height: 150), // พื้นที่เผื่อปุ่มกดด้านล่าง
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- หน้าที่ 2: รายการไพ่ ---
  Widget _buildDeckCardsGridView(BuildContext context, Map<String, dynamic> args) {
    int cardCount = int.tryParse(args['cardCount'].toString()) ?? 0;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && !_isAnimating) {
          // Logic: ถ้าไถกลับจนถึงขอบบนสุดแล้วไถต่อ -> สั่ง PageView กลับไปหน้า 0
          if (_gridScrollController.position.pixels <= 0 && notification.scrollDelta! < -8) {
            _goToPage(0);
          }
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
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
          Expanded(
            child: GridView.builder(
              controller: _gridScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12
              ),
              itemCount: cardCount,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _showCardFlipDetail(context), // กดดูการพลิกไพ่ได้จริง
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
                ),
              ),
            ),
          ),
          // ข้อความ Hint ด้านล่างสุด (Permanent Hint)
          const Padding(
            padding: EdgeInsets.only(top: 15, bottom: 5),
            child: Column(
              children: [
                Text("ปัดลงเพื่อกลับหน้าข้อมูล ↓", style: TextStyle(color: Colors.white30, fontSize: 12)),
                Icon(Icons.keyboard_arrow_down, color: Colors.white24, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  // --- Widget เสริม: บรรทัดข้อมูล ---
  Widget _infoRow(String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [Text("$title : $value", style: const TextStyle(color: Colors.white70, fontSize: 15))]),
  );

  // --- Widget เสริม: กลุ่มปุ่มด้านล่าง ---
  Widget _buildBottomButtons(BuildContext context) => Positioned(
    bottom: 30, left: 20, right: 20,
    child: Row(
      children: [
        Expanded(child: _actionButton("ลบสำรับทิ้ง", Colors.redAccent, () => _showDeleteDialog(context))),
      ],
    ),
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

  // --- Logic: แสดง Pop-up ยืนยันการลบ ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: const Text("คำเตือน!!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("ยืนยันจะลบสำรับนี้ถาวรหรือไม่? ข้อมูลจะหายไปจากรายการทันที", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก", style: TextStyle(color: Colors.white30))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), 
            onPressed: () {
              Navigator.pop(context); // ปิด Dialog
              Navigator.pop(context, "delete"); // ส่งคำสั่ง "delete" กลับไปยังหน้า User Detail
            }, 
            child: const Text("ยืนยันการลบ")
          )
        ],
      ),
    );
  }

  // --- Logic: นำทางไปหน้าพลิกไพ่ ---
  void _showCardFlipDetail(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CardFlipView()));
  }
}

// --- 3. หน้าพลิกไพ่ 3D (รวมไว้ในนี้เพื่อให้กดดูได้ทันที) ---
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
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)))
      ],
    )
  );
}
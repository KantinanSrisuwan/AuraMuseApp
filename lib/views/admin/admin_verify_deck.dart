import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/firestore_service.dart';

// ==========================================================
// 1. หน้าหลัก (Controller)
// ==========================================================
class AdminVerifyDeckPage extends StatefulWidget {
  const AdminVerifyDeckPage({super.key});
  @override State<AdminVerifyDeckPage> createState() => _AdminVerifyDeckPageState();
}

class _AdminVerifyDeckPageState extends State<AdminVerifyDeckPage> {
  final PageController _pageController = PageController();
  late String _deckId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _deckId = args['deckId'] ?? '';
  }

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
              VerifyGridPart(args: args, onBack: () => _jumpToPage(0)),
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
            Expanded(child: _actionButton("ยืนยัน", isAllow ? Colors.green : Colors.redAccent, () async {
              if (isAllow) {
                final success = await FirestoreService.updateDeckStatus(_deckId, 'verified');
                if (mounted && success) {
                  Navigator.of(context)..pop()..pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ยืนยันการอนุญาตสำรับเสร็จสิ้น'), backgroundColor: Colors.green)
                  );
                }
              } else {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาระบุเหตุผลที่ปฏิเสธ'), backgroundColor: Colors.orange)
                  );
                  return;
                }
                final success = await FirestoreService.rejectDeckVerification(_deckId, reason);
                if (mounted && success) {
                  Navigator.of(context)..pop()..pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ปฏิเสธสำรับเรียบร้อยแล้ว'), backgroundColor: Colors.redAccent)
                  );
                }
              }
            })),
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
class VerifyInfoPart extends StatefulWidget {
  final dynamic args;
  final VoidCallback onNext;
  const VerifyInfoPart({super.key, required this.args, required this.onNext});

  @override
  State<VerifyInfoPart> createState() => _VerifyInfoPartState();
}

class _VerifyInfoPartState extends State<VerifyInfoPart> {
  @override
  Widget build(BuildContext context) {
    // สร้าง DeckModel จาก arguments แทนการดึง getDeckById ใหม่
    // เพื่อให้ viewCount/drawCount ตรงกับ dashboard
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && notification.metrics.pixels >= notification.metrics.maxScrollExtent && notification.scrollDelta! > 5) {
          widget.onNext();
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
                widget.args['deckName'] ?? "ชื่อสำรับ",
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
                      Container(
                        width: 160, 
                        height: 250, 
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3AFF), 
                          borderRadius: BorderRadius.circular(15), 
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5))
                        ), 
                        child: const Icon(Icons.style, size: 90, color: Colors.white24)
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _infoRow("หมายเลขเด็ค", widget.args['deckId'] ?? "-"),
                            _infoRow("จำนวนการ์ด", "${widget.args['cardCount']} ใบ"),
                            _infoRow("ผู้สร้าง", widget.args['creatorUsername'] ?? "ไม่ระบุ"),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("สถานะเด็ค :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (widget.args['deckStatus'] ?? 'unverified') == 'verified' ? Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (widget.args['deckStatus'] ?? 'unverified') == 'verified' ? '✓ Verified' : '⊙ Unverified',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Text("สถิติการเข้าชมและสุ่มไพ่", style: TextStyle(color: Colors.white60, fontSize: 16)),
                  const SizedBox(height: 25),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // จำนวนการเข้าชม
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.cyan, width: 3),
                              color: Colors.cyan.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.args['viewCount'] ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'เข้าชม',
                                    style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'จำนวนการเข้าชม',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      
                      // จำนวนการสุ่ม
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.lime, width: 3),
                              color: Colors.lime.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.args['drawCount'] ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.lime,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'ครั้ง',
                                    style: TextStyle(
                                      color: Colors.lime,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'จำนวนการสุ่ม',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  const Text("ไถขึ้นเพื่อดูไพ่ในสำรับ ↑", style: TextStyle(color: Colors.white24, fontSize: 12)),
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
// 3. ไฟล์หน้ารายการไพ่ (VerifyGridPart)
// ==========================================================
class VerifyGridPart extends StatefulWidget {
  final dynamic args;
  final VoidCallback onBack;
  const VerifyGridPart({super.key, required this.args, required this.onBack});

  @override
  State<VerifyGridPart> createState() => _VerifyGridPartState();
}

class _VerifyGridPartState extends State<VerifyGridPart> {
  @override
  Widget build(BuildContext context) {
    final deckId = widget.args['deckId'] ?? '';
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService.getCardsByDeckId(deckId),
      builder: (context, snapshot) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification && notification.metrics.pixels <= 0 && notification.scrollDelta! < -5) {
              widget.onBack();
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
                    Text(
                      widget.args['deckName'] ?? "ชื่อสำรับ", 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      "${snapshot.data?.length ?? 0} ใบ", 
                      style: const TextStyle(color: Colors.white70, fontSize: 16)
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white24, indent: 20, endIndent: 20, height: 30),
              
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty
                    ? const Center(child: Text("ไม่มีการ์ด", style: TextStyle(color: Colors.white70)))
                    : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20), 
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12
                      ), 
                      itemCount: snapshot.data!.length, 
                      itemBuilder: (c, i) {
                        final card = snapshot.data![i];
                        final frontImage = card['front_image'] ?? '';
                        final backText = card['back_text'] ?? 'ไม่มีข้อความ';
                        
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (c) => CardFlipView(
                                frontImage: frontImage,
                                backText: backText,
                              ),
                            ),
                          ), 
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10, 
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
                            ), 
                            child: frontImage.isNotEmpty
                              ? Image.network(
                                  frontImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.style, color: Colors.orangeAccent);
                                  },
                                )
                              : const Icon(Icons.style, color: Colors.orangeAccent),
                          ),
                        );
                      },
                    ),
              ),
              const Text("ไถลงเพื่อกลับ ↓", style: TextStyle(color: Colors.white24, fontSize: 12)),
              const SizedBox(height: 110),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================================
// 4. CardFlipView - สำหรับแสดงการ์ด (หน้า/หลัง)
// ==========================================================
class CardFlipView extends StatefulWidget {
  final String frontImage;
  final String backText;

  const CardFlipView({
    super.key,
    this.frontImage = '',
    this.backText = 'ไม่มีข้อความ',
  });

  @override
  State<CardFlipView> createState() => _CardFlipViewState();
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
                        ? _cardFront()
                        : Transform(
                            transform: Matrix4.rotationY(pi),
                            alignment: Alignment.center,
                            child: _cardBack(),
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
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
      ),
    );
  }

  Widget _cardFront() {
    return Container(
      width: 280,
      height: 450,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3),
      ),
      child: widget.frontImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Image.network(
                widget.frontImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_not_supported, size: 80, color: Colors.orangeAccent),
                      SizedBox(height: 20),
                      Text(
                        'ไม่สามารถโหลดรูป',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wb_sunny, size: 100, color: Colors.orangeAccent),
                  SizedBox(height: 30),
                  Text(
                    'รูปภาพไพ่\n(ด้านหน้า)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _cardBack() {
    return Container(
      width: 280,
      height: 450,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, size: 100, color: Colors.orangeAccent),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.backText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
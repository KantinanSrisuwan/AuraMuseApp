import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/firestore_service.dart';

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
    // ดึง arguments จาก route (อาจจะเป็น null หรือไม่มีครบทั้งหมด)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    
    // ถ้าไม่มี deckId ใน arguments แสดง error
    if ((args['deckId'] ?? '').isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF13112B),
        body: Center(
          child: Text('ไม่สามารถหา ID ของสำรับได้', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    bool isPublic = args['isPublic'] ?? false;
    String deckStatus = args['deckStatus'] ?? "unverified"; // ดึงจาก args

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: Stack(
        children: [
          // ถ้า arguments ไม่มี creatorUsername ให้ดึงจาก Firestore
          (args['creatorUsername'] ?? '').isEmpty
            ? _buildDeckDetailWithFetch(args, isPublic, deckStatus)
            : _buildDeckDetail(args, isPublic, deckStatus),
          // ปุ่ม Action ลอยคงที่ (เฉพาะของหน้า Deck)
          _buildBottomButtons(context, args['deckId'] ?? ''),
        ],
      ),
    );
  }

  // สร้าง Deck Detail โดยดึงข้อมูลจาก Firebase
  Widget _buildDeckDetailWithFetch(Map<String, dynamic> args, bool isPublic, String deckStatus) {
    return FutureBuilder<DeckModel?>(
      future: FirestoreService.getDeckById(args['deckId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        // ถ้าดึงมาได้ ให้รวมข้อมูลจาก Firestore กับ arguments
        if (snapshot.hasData && snapshot.data != null) {
          final deck = snapshot.data!;
          final mergedArgs = {
            ...args,
            'deckName': deck.deckName,
            'cardCount': deck.cardCount,
            'creatorUsername': deck.creatorUsername,
            'viewCount': deck.viewCount,
            'drawCount': deck.drawCount,
            'deckStatus': deck.deckStatus,
            'coverImage': deck.coverImage,
          };
          return _buildDeckDetail(mergedArgs, isPublic, deckStatus);
        }

        return Center(
          child: Text('ไม่สามารถดึงข้อมูลสำรับได้', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  // สร้าง Deck Detail โดยใช้ข้อมูลจาก arguments
  Widget _buildDeckDetail(Map<String, dynamic> args, bool isPublic, String deckStatus) {
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      children: [
        // --- ไฟล์ที่ 1: รายละเอียดสำรับ ---
        DeckInfoPart(args: args, isPublic: isPublic, deckStatus: deckStatus, onNext: () => _jumpToPage(1)),
        // --- ไฟล์ที่ 2: รายการไพ่ในสำรับ ---
        DeckGridPart(args: args, onBack: () => _jumpToPage(0)),
      ],
    );
  }

  // --- ส่วนปุ่มกดยันยืนการลบ (ดีไซน์เดิมของหน้า Deck) ---
  Widget _buildBottomButtons(BuildContext context, String deckId) => Positioned(
    bottom: 30, left: 20, right: 20,
    child: Row(children: [
      Expanded(child: _actionButton("ลบสำรับทิ้ง", Colors.redAccent, () => _showDeleteDialog(context, deckId))),
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

  void _showDeleteDialog(BuildContext parentContext, String deckId) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: const Text("คำเตือน!!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("การลบข้อมูลนี้เป็นการลบข้อมูลของสำรับถาวร ยืนยันที่จะลบหรือไม่", style: TextStyle(color: Colors.white70)),
        actions: [
          Row(children: [
            Expanded(
              child: _actionButton("ยืนยัน", Colors.redAccent, () async {
                // ลบ deck จาก Firebase
                bool success = await FirestoreService.deleteDeck(deckId);
                
                Navigator.of(dialogContext).pop(); // ปิด dialog
                if (success) {
                  Navigator.of(parentContext).pop(); // กลับไปหน้าก่อนหน้า
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('ไม่สามารถลบสำรับได้'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }),
            ),
            const SizedBox(width: 10),
            Expanded(child: _actionButton("ยกเลิก", const Color(0xFF455A64), () => Navigator.pop(dialogContext))),
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
  final String deckStatus;
  final VoidCallback onNext;
  
  const DeckInfoPart({
    super.key, 
    required this.args, 
    required this.isPublic, 
    required this.deckStatus, 
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
                      // รูปปกจริง
                      Container(
                        width: 160,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3AFF),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))],
                        ),
                        child: (args['coverImage'] as String?)?.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.network(
                                  args['coverImage'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.style, size: 90, color: Colors.white24);
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: Colors.blueAccent,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Icon(Icons.style, size: 90, color: Colors.white24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 20),
                        _infoRow("หมายเลขเด็ค", args['deckId'] ?? "-"),
                        _infoRow("จำนวนการ์ด", "${args['cardCount']} ใบ"),
                        _infoRow("ผู้สร้าง", args['creatorUsername'] ?? "ไม่ระบุ"),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("สถานะเด็ค :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: deckStatus == 'verified' ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                deckStatus == 'verified' ? '✓ Verified' : '⊙ Unverified',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Text("สถิติการเข้าชมและสุ่มไพ่", style: TextStyle(color: Colors.white60, fontSize: 16)),
                  const SizedBox(height: 25),
                  
                  // แสดงสถิติการเข้าชมและสุ่มไพ่
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
                                    '${args['viewCount'] ?? 0}',
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
                                    '${args['drawCount'] ?? 0}',
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
class DeckGridPart extends StatefulWidget {
  final Map<String, dynamic> args;
  final VoidCallback onBack;
  const DeckGridPart({super.key, required this.args, required this.onBack});

  @override
  State<DeckGridPart> createState() => _DeckGridPartState();
}

class _DeckGridPartState extends State<DeckGridPart> {
  @override
  Widget build(BuildContext context) {
    int cardCount = int.tryParse(widget.args['cardCount'].toString()) ?? 0;
    String deckId = widget.args['deckId'] ?? '';

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // ถ้าไถลงจนสุดขอบบนแล้ว ให้สั่งกลับหน้าข้อมูล
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
                Text(widget.args['deckName'] ?? "สำรับ", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("$cardCount ใบ", style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Divider(color: Colors.white24, indent: 20, endIndent: 20, height: 30),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: FirestoreService.getCardsByDeckId(deckId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'เกิดข้อผิดพลาด: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final cards = snapshot.data ?? [];

                if (cards.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีไพ่ในสำรับนี้',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    childAspectRatio: 0.7, 
                    crossAxisSpacing: 12, 
                    mainAxisSpacing: 12
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => CardFlipView(
                            frontImage: card['front_image'] ?? '',
                            backText: card['back_text'] ?? 'ไม่มีข้อความ',
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
                        ),
                        child: card['front_image'] != null && card['front_image']!.isNotEmpty
                            ? Image.network(
                                card['front_image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
                              )
                            : const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
                      ),
                    );
                  },
                );
              },
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
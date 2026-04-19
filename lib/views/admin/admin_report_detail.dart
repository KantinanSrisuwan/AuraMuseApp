import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================================
// 1. หน้าหลัก (Controller) - คุมการเปลี่ยนไฟล์หน้า 1 และ 2
// ==========================================================
class AdminReportDetailPage extends StatefulWidget {
  const AdminReportDetailPage({super.key});
  @override State<AdminReportDetailPage> createState() => _AdminReportDetailPageState();
}

class _AdminReportDetailPageState extends State<AdminReportDetailPage> {
  final PageController _pageController = PageController();
  late Future<Map<String, dynamic>> _deckDataFuture;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _fetchDeckData(String deckId) async {
    try {
      if (deckId.isEmpty) {
        return {
          'deckId': '',
          'deckName': 'ไม่มี ID',
          'cardCount': 0,
          'coverImage': '',
          'creatorUsername': '-',
          'description': 'ไม่มี deckId',
          'reportsList': [],
        };
      }

      final deck = await FirestoreService.getDeckById(deckId);
      if (deck != null) {
        // ดึงข้อมูล reports field จาก deck
        final decksCollection = FirebaseFirestore.instance.collection('decks');
        final deckDoc = await decksCollection.doc(deckId).get();
        final deckData = deckDoc.data() as Map<String, dynamic>?;
        final reportsList = (deckData?['reports'] as List?) ?? [];
        
        // สร้างสรุป reports
        String reportsDescription = 'ไม่มีการรายงาน';
        if (reportsList.isNotEmpty) {
          reportsDescription = 'จำนวนการรายงาน: ${reportsList.length} ครั้ง\n\n';
          for (int i = 0; i < reportsList.length && i < 3; i++) {
            reportsDescription += '${i + 1}. ${reportsList[i]}\n';
          }
          if (reportsList.length > 3) {
            reportsDescription += '\nและข้ออื่นอีก ${reportsList.length - 3} รายการ';
          }
        }

        return {
          'deckId': deckId,
          'deckName': deck.deckName,
          'cardCount': deck.cardCount,
          'coverImage': deck.coverImage,
          'creatorUsername': deck.creatorUsername,
          'createdAt': deck.createdAt.toString(),
          'reportsList': reportsList,
          'description': reportsDescription,
          'deckStatus': deck.deckStatus,
          'viewCount': deck.viewCount,
          'drawCount': deck.drawCount,
        };
      }
      return {
        'deckId': deckId,
        'deckName': 'ไม่พบสำรับ',
        'cardCount': 0,
        'coverImage': '',
        'creatorUsername': '-',
        'description': 'ไม่พบข้อมูลเด็ค',
        'reportsList': [],
      };
    } catch (e) {
      print('Error fetching deck data: $e');
      return {
        'deckId': deckId,
        'deckName': 'ข้อผิดพลาด',
        'cardCount': 0,
        'coverImage': '',
        'creatorUsername': '-',
        'description': 'เกิดข้อผิดพลาด: $e',
        'reportsList': [],
      };
    }
  }

  void _jumpToPage(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  @override
  Widget build(BuildContext context) {
    // ดึง arguments ตอนแรกเท่านั้น
    if (!_isInitialized) {
      try {
        final args = ModalRoute.of(context)?.settings.arguments;
        String deckId = '';
        
        if (args != null && args is Map) {
          deckId = (args['deckId'] as String?) ?? '';
        }
        
        _deckDataFuture = _fetchDeckData(deckId);
      } catch (e) {
        print('Error extracting arguments: $e');
        _deckDataFuture = Future.value({
          'deckId': '',
          'deckName': 'ข้อผิดพลาด',
          'cardCount': 0,
          'coverImage': '',
          'creatorUsername': '-',
          'description': 'เกิดข้อผิดพลาดในการดึง arguments',
          'reportsList': [],
        });
      }
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _deckDataFuture,
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

          final deckData = snapshot.data;
          if (deckData == null) {
            return const Center(
              child: Text(
                'ไม่สามารถโหลดข้อมูลสำรับ',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                children: [
                  ReportInfoPart(args: deckData, onNext: () => _jumpToPage(1)),
                  ReportGridPart(args: deckData, onBack: () => _jumpToPage(0)),
                ],
              ),
              _buildBottomButtons(context, deckData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, Map<String, dynamic>? deckData) {
    if (deckData == null) {
      return const SizedBox.shrink();
    }
    
    final deckId = (deckData['deckId'] as String?) ?? '';
    
    // ถ้าไม่มี deckId ให้ disable ปุ่ม
    if (deckId.isEmpty) {
      return Positioned(
        bottom: 30, 
        left: 20, 
        right: 20,
        child: Row(children: [
          Expanded(child: _btn("ยอมรับการรายงาน", Colors.grey, () {})),
          const SizedBox(width: 15),
          Expanded(child: _btn("ปฏิเสธการรายงาน", Colors.grey, () {})),
        ]),
      );
    }

    return Positioned(
      bottom: 30, 
      left: 20, 
      right: 20,
      child: Row(children: [
        Expanded(child: _btn("ยอมรับการรายงาน", Colors.redAccent, () {
          _showAcceptDialog(context, deckId);
        })),
        const SizedBox(width: 15),
        Expanded(child: _btn("ปฏิเสธการรายงาน", const Color(0xFF455A64), () {
          _showRejectDialog(context, deckId);
        })),
      ]),
    );
  }

  Widget _btn(String t, Color c, VoidCallback f) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: c, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: f, child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)));

  void _showAcceptDialog(BuildContext context, String deckId) {
    print('🔍 DEBUG: _showAcceptDialog called with deckId: $deckId');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: const Text("ยืนยัน", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("ต้องการยอมรับการรายงานนี้หรือไม่? (สำรับนี้จะถูกซ่อนจากผู้ใช้ทั้งหมด)", style: TextStyle(color: Colors.white70)),
        actions: [
          Row(children: [
            Expanded(
              child: _btn(
                "ยืนยัน",
                Colors.redAccent,
                () async {
                  print('🔍 DEBUG: Accept report button pressed, deckId: $deckId');
                  print('🔍 DEBUG: mounted before async: $mounted');
                  
                  // ล้าง keyboard ก่อนปิด dialog
                  FocusScope.of(context).unfocus();
                  
                  // เรียก Firestore service ยอมรับ report
                  final success = await FirestoreService.acceptDeckReport(deckId);
                  
                  print('🔍 DEBUG: FirestoreService.acceptDeckReport returned: $success');
                  print('🔍 DEBUG: mounted after async: $mounted');

                  if (!mounted) return;

                  if (success) {
                    // ปิด dialog ก่อน
                    if (mounted) Navigator.pop(context);
                    // ปิด report detail page
                    if (mounted) Navigator.pop(context);
                    
                    // แสดง SnackBar
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ยอมรับการรายงานสำเร็จ')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('เกิดข้อผิดพลาดในการยอมรับการรายงาน')),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _btn("ยกเลิก", Colors.blueGrey[700]!, () => Navigator.pop(context))),
          ]),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  // ✅ ✅ ✅ คืนค่า: รายการเหตุผลที่ปฏิเสธ (Checkbox List)
  void _showRejectDialog(BuildContext context, String deckId) {
    print('🔍 DEBUG: _showRejectDialog called with deckId: $deckId');
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
              Expanded(
                child: _btn(
                  "ยืนยัน",
                  const Color(0xFF4A3AFF),
                  () async {
                    print('🔍 DEBUG: Reject button pressed, deckId: $deckId');
                    print('🔍 DEBUG: mounted before async: $mounted');
                    
                    // ล้าง keyboard ก่อนปิด dialog
                    FocusScope.of(context).unfocus();
                    
                    // เก็บเหตุผลที่เลือก
                    List<String> selectedReasons = [];
                    for (int i = 0; i < isChecked.length; i++) {
                      if (isChecked[i]) {
                        selectedReasons.add(reasons[i]);
                      }
                    }

                    if (selectedReasons.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเลือกเหตุผลอย่างน้อย 1 รายการ')),
                      );
                      return;
                    }

                    // สร้างข้อความของเหตุผล
                    String rejectReasonText = selectedReasons.join(', ');

                    // เรียก Firestore service ปฏิเสธการรายงาน
                    final success = await FirestoreService.rejectDeckReport(deckId, rejectReasonText);
                    
                    print('🔍 DEBUG: FirestoreService.rejectDeckReport returned: $success');
                    print('🔍 DEBUG: mounted after async: $mounted');

                    if (!mounted) return;

                    if (success) {
                      // ปิด dialog ก่อน
                      if (mounted) Navigator.pop(context);
                      // ปิด report detail page
                      if (mounted) Navigator.pop(context);
                      
                      // แสดง SnackBar
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ปฏิเสธการรายงานสำเร็จ')),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('เกิดข้อผิดพลาดในการปฏิเสธการรายงาน')),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _btn("ยกเลิก", Colors.blueGrey[700]!, () => Navigator.pop(context))),
            ]),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        ),
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
                    // รูปปกจริง
                    Container(
                      width: 160,
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3AFF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, 8))],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text("ID: ${args['deckId']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 5),
                          Text("สร้างโดย: ${args['creatorUsername'] ?? '-'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 5),
                          Text("จำนวน: ${args['cardCount']} ใบ", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("สถานะ : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: args['deckStatus'] == 'verified' ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  args['deckStatus'] == 'verified' ? '✓ Verified' : '⊙ Unverified',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 35),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "รายการการรายงาน:",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          args['description'] ?? "ไม่มีการรายงาน",
                          style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  const Text("ไถขึ้นเพื่อสลับไปไฟล์รายการไพ่ ↑", style: TextStyle(color: Colors.white24, fontSize: 12)),
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
// 3. ไฟล์หน้ารายการไพ่ (ReportGridPart)
// ==========================================================
class ReportGridPart extends StatefulWidget {
  final dynamic args;
  final VoidCallback onBack;
  const ReportGridPart({super.key, required this.args, required this.onBack});

  @override
  State<ReportGridPart> createState() => _ReportGridPartState();
}

class _ReportGridPartState extends State<ReportGridPart> {
  @override
  Widget build(BuildContext context) {
    int cardCount = int.tryParse(widget.args['cardCount'].toString()) ?? 0;
    String deckId = widget.args['deckId'] ?? '';

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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ==========================================================
// 4. หน้าพลิกไพ่ 3D (CardFlipView) - คืนชีพฟีเจอร์เดิมครบชุด
// ==========================================================
// ==========================================================
// 4. หน้าพลิกไพ่ 3D (CardFlipView)
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

  Widget _cardFront() => Container(
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
              errorBuilder: (context, error, stackTrace) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 100, color: Colors.orangeAccent),
                    SizedBox(height: 20),
                    Text(
                      'ไม่สามารถโหลดรูปภาพ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.orangeAccent,
                  ),
                );
              },
            ),
          )
        : const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 100, color: Colors.orangeAccent),
              SizedBox(height: 20),
              Text(
                'ไม่มีรูปภาพ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
  );

  Widget _cardBack() => Container(
    width: 280,
    height: 450,
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 3),
    ),
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, size: 80, color: Colors.orangeAccent),
          const SizedBox(height: 30),
          Text(
            widget.backText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}
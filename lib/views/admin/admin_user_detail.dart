import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/firestore_service.dart';
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class AdminUserDetailPage extends StatefulWidget {
  const AdminUserDetailPage({super.key});
  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  int deckCategoryIndex = 0;
  final List<String> categories = ["สำรับที่รอตรวจสอบ", "สำรับที่ได้รับการยืนยันแล้ว"];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'] ?? '';
    final username = args['username'] ?? 'ไม่ระบุ';
    final email = args['email'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileHeader(userId, username, email),
                  const SizedBox(height: 30),
                  FutureBuilder(
                    future: FirestoreService.getDecksByCreator(userId),
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

                      final allDecks = snapshot.data ?? [];
                      final filteredDecks = _filterDecksByCategory(allDecks);

                      return _buildDeckSlider(filteredDecks);
                    },
                  ),
                  const SizedBox(height: 150), // เผื่อที่ให้ปุ่มด้านล่าง
                ],
              ),
            ),
            _buildActionButtons(context, userId),
          ],
        ),
      ),
    );
  }

  // --- Widget: ส่วนหัวโปรไฟล์ ---
  Widget _buildProfileHeader(String userId, String username, String email) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 65, 
          backgroundColor: Colors.deepPurple, 
          child: Icon(Icons.person, size: 80, color: Colors.white),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoText("หมายเลข user", userId),
          _infoText("Username", username),
          _infoText("EMAIL", email),
        ])),
      ],
    );
  }

  // ฟังก์ชันสำหรับแบ่งเด็คตามสถานะ
  List<DeckModel> _filterDecksByCategory(List<DeckModel> allDecks) {
    if (deckCategoryIndex == 0) {
      // สำรับที่รอตรวจสอบ
      return allDecks.where((d) => d.deckStatus == 'unverified').toList();
    } else {
      // สำรับที่ได้รับการยืนยันแล้ว
      return allDecks.where((d) => d.deckStatus == 'verified').toList();
    }
  }

  // --- Widget: Container แสดงสำรับ (พร้อมลูกศรสลับประเภท) ---
  Widget _buildDeckSlider(List<DeckModel> currentList) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3F), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: deckCategoryIndex > 0 ? Colors.white : Colors.white24, size: 20), 
                onPressed: deckCategoryIndex > 0 ? () => setState(() => deckCategoryIndex--) : null
              ),
              Text(categories[deckCategoryIndex], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: deckCategoryIndex < 1 ? Colors.white : Colors.white24, size: 20), 
                onPressed: deckCategoryIndex < 1 ? () => setState(() => deckCategoryIndex++) : null
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          SizedBox(
            height: 200,
            child: currentList.isEmpty 
              ? const Center(child: Text("ไม่มีข้อมูลสำรับ", style: TextStyle(color: Colors.white24)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentList.length,
                  itemBuilder: (context, index) => _buildDeckCard(currentList[index], index),
                ),
          ),
        ],
      ),
    );
  }

  // --- Widget: การ์ดสำรับใบย่อย ---
  Widget _buildDeckCard(DeckModel deck, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          deck.deckStatus == 'unverified' ? '/admin/verify_detail' : '/admin/deck_detail', 
          arguments: {
            'deckId': deck.id, 
            'deckName': deck.deckName, 
            'cardCount': deck.cardCount.toString(),
            'deckStatus': deck.deckStatus,
            'creatorUsername': deck.creatorUsername,
            'viewCount': deck.viewCount,
            'drawCount': deck.drawCount,
          }
        ).then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      },
      child: Container(
        width: 120, margin: const EdgeInsets.only(right: 15, top: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(10), 
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5), 
              child: Text(deck.deckName, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)
            ),
            Text("${deck.cardCount} ใบ", style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text("$l : $v", style: const TextStyle(color: Colors.white70, fontSize: 13)));

  // --- Widget: กลุ่มปุ่มด้านล่าง ---
  Widget _buildActionButtons(BuildContext context, String userId) {
    return Positioned(
      bottom: 30, left: 20, right: 20, 
      child: Row(
        children: [
          Expanded(child: _btn("แก้ไขข้อมูล", const Color.fromARGB(248, 255, 208, 0), Colors.white, () => Navigator.pushNamed(context, '/admin_edit_user', arguments: {'userId': userId}))),
          const SizedBox(width: 15),
          Expanded(child: _btn("ลบบัญชี", Colors.redAccent, Colors.white, () => _showDeleteUserDialog(context, userId))),
        ],
      ),
    );
  }

  // --- Widget เสริม: ปุ่มกดสไตล์มาตรฐาน ---
  Widget _btn(String t, Color bg, Color tc, VoidCallback fn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, 
        padding: const EdgeInsets.symmetric(vertical: 18), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: fn, 
      child: Text(t, style: TextStyle(color: tc, fontWeight: FontWeight.bold, fontSize: 16))
    );
  }

  // --- Pop-up ยืนยันการลบบัญชี ---
  void _showDeleteUserDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.redAccent, width: 2), 
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text("คำเตือน!! (ลบบัญชี)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: const Text(
            "การลบบัญชีผู้ใช้จะเป็นการลบข้อมูลถาวร รวมถึงสำรับไพ่ทั้งหมด บัญชีนี้จะไม่สามารถกู้คืนได้อีก ท่านแน่ใจหรือไม่ที่จะดำเนินการต่อ?",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            Row(
              children: [
                Expanded(child: _btn("ยืนยันการลบ", Colors.redAccent, Colors.white, () async {
                  await FirestoreService.deleteUser(userId);
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                })),
                const SizedBox(width: 10),
                Expanded(child: _btn("ยกเลิก", const Color(0xFF455A64), Colors.white, () => Navigator.pop(dialogContext))),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        );
      },
    );
  }
}
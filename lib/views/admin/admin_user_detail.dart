import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../../core/routes/admin_routes.dart'; // ตรวจสอบ path ให้ตรงกับโปรเจกต์คุณ

class DeckModel {
  final String id;
  final String name;
  final int cardCount;
  final String status; // เปลี่ยนจาก bool เป็น String เพื่อความชัวร์
  final bool isWaiting;
  final bool isPublic;

  DeckModel({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.status,
    this.isWaiting = false,
    this.isPublic = false,
  });
}

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
  String username = "ราชาคนุษยัยามดึก";
  String email = "tokjaiz01@gmail.com";
  int deckCategoryIndex = 0;
  final List<String> categories = ["สำรับที่รอการตรวจสอบ", "สำรับที่เผยแพร่สู่สาธารณะ", "สำรับส่วนตัว"];

  List<DeckModel> waitingDecks = [];
  List<DeckModel> publicDecks = [];
  List<DeckModel> privateDecks = [];

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  void _initMockData() {
    final rand = Random();
    List<String> pool = ["คัมภีร์ลับ", "มนตราดำ", "แสงแห่งเทพ", "บทกวีพงไพร", "เงาจันทร์", "ตำนานมังกร"];
    
    // 1. สำรับรอตรวจสอบ: สถานะต้องเป็น "รอการตรวจสอบ"
    waitingDecks = List.generate(3, (i) => DeckModel(
      id: "W-${100+i}", 
      name: "${pool[rand.nextInt(pool.length)]} #${i+1}", 
      cardCount: 5 + rand.nextInt(10), 
      status: "รอการตรวจสอบ",
      isWaiting: true
    ));

    // 2. สำรับสาธารณะ: สถานะต้องเป็น "เผยแพร่แล้ว"
    publicDecks = List.generate(5, (i) => DeckModel(
      id: "P-${200+i}", 
      name: "${pool[rand.nextInt(pool.length)]} #${i+1}", 
      cardCount: 15 + rand.nextInt(10), 
      status: "เผยแพร่แล้ว",
      isPublic: true
    ));

    // 3. สำรับส่วนตัว: สถานะต้องเป็น "ส่วนตัว"
    privateDecks = List.generate(4, (i) => DeckModel(
      id: "PV-${300+i}", 
      name: "${pool[rand.nextInt(pool.length)]} #${i+1}", 
      cardCount: 10 + rand.nextInt(5),
      status: "ส่วนตัว"
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    List<DeckModel> activeList = deckCategoryIndex == 0 ? waitingDecks : (deckCategoryIndex == 1 ? publicDecks : privateDecks);

    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
      ),
      body: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 65, backgroundColor: Colors.deepPurple, backgroundImage: NetworkImage("https://picsum.photos/seed/${args?['userId'] ?? 'user'}/200")),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _infoText("หมายเลข user", args?['userId'] ?? "1082"),
                        _infoText("Username", username),
                        _infoText("EMAIL", email),
                        _infoText("รวมสำรับทั้งหมด", "${waitingDecks.length + publicDecks.length + privateDecks.length}"),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A3F), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(icon: Icon(Icons.arrow_back_ios, color: deckCategoryIndex > 0 ? Colors.white : Colors.white24), 
                              onPressed: deckCategoryIndex > 0 ? () => setState(() => deckCategoryIndex--) : null),
                            Text(categories[deckCategoryIndex], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            IconButton(icon: Icon(Icons.arrow_forward_ios, color: deckCategoryIndex < 2 ? Colors.white : Colors.white24), 
                              onPressed: deckCategoryIndex < 2 ? () => setState(() => deckCategoryIndex++) : null),
                          ],
                        ),
                        const Divider(color: Colors.white12),
                        SizedBox(
                          height: 200,
                          child: activeList.isEmpty 
                            ? const Center(child: Text("ไม่มีสำรับในหมวดนี้", style: TextStyle(color: Colors.white24)))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: activeList.length,
                                itemBuilder: (context, index) => _buildDeckCard(activeList[index], index),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCard(DeckModel deck, int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context, 
          deck.isWaiting ? AdminRoutes.adminVerifyDetail : AdminRoutes.adminDeckDetail, 
          arguments: {
            'deckId': deck.id, 
            'deckName': deck.name, 
            'cardCount': deck.cardCount.toString(),
            'isPublic': deck.isPublic, 
            'status': deck.status // ส่งสถานะที่ตรงกับหมวดหมู่ไป
          }
        );
        if (result == "delete") {
          setState(() {
            if (deckCategoryIndex == 0) waitingDecks.removeAt(index);
            else if (deckCategoryIndex == 1) publicDecks.removeAt(index);
            else privateDecks.removeAt(index);
          });
        }
      },
      child: Container(
        width: 120, margin: const EdgeInsets.only(right: 15, top: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, color: Colors.orangeAccent, size: 40),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(deck.name, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis)),
            Text("${deck.cardCount} ใบ", style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text("$l : $v", style: const TextStyle(color: Colors.white70, fontSize: 13)));

  Widget _buildBottomButtons() => Positioned(bottom: 30, left: 20, right: 20, child: Row(children: [
    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4C11E), padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () => Navigator.pushNamed(context, AdminRoutes.adminEditUser), child: const Text("แก้ไขข้อมูล", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 15),
    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () {}, child: const Text("ลบบัญชี", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
  ]));
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/admin_drawer.dart';
import '../../services/firestore_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // กำหนดเมนูที่กำลังเลือกอยู่ (เพื่อทำ Highlight)
  String currentRoute = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13112B), // สีพื้นหลังน้ำเงินเข้มตามรูป
      // 1. ปุ่มเบอร์เกอร์บาร์ (ปุ่มซ้ายบน)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      // 2. แถบเมนูซ้ายมือ (Drawer)
      drawer: const AdminDrawer(currentRoute: 'Home'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // หัวข้อส่วนบน
            const Text(
              "สำรับที่มีคนเข้าชมเยอะที่สุด 5 อันดับ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),
            // ส่วนกราฟรูปวงกลม
            Expanded(
              child: FutureBuilder(
                future: FirestoreService.getAllDecks(),
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

                  final decks = snapshot.data ?? <DeckModel>[];
                  
                  // เรียงเด็คตาม viewCount จากมากไปน้อย แล้วเอา 5 อันดับ
                  final topDecks = List<DeckModel>.from(decks)
                    ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
                  final top5 = topDecks.take(5).toList();

                  if (top5.isEmpty) {
                    return const Center(
                      child: Text(
                        'ยังไม่มีข้อมูล',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // === ส่วนกราฟรูปวงกลม ===
                        _buildPieChartSection(top5),
                        const SizedBox(height: 40),
                        
                        // === ส่วนรายการแบบเดิม ===
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: top5.length,
                            itemBuilder: (context, index) {
                              final deck = top5[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/admin/deck_detail',
                                    arguments: {
                                      'deckId': deck.id,
                                      'deckName': deck.deckName,
                                      'cardCount': deck.cardCount.toString(),
                                      'deckStatus': deck.deckStatus,
                                      'creatorUsername': deck.creatorUsername,
                                      'viewCount': deck.viewCount,
                                      'drawCount': deck.drawCount,
                                    }
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      // ลำดับที่
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index == 0
                                              ? Colors.amber
                                              : index == 1
                                                  ? Colors.grey[400]
                                                  : index == 2
                                                      ? Colors.brown
                                                      : Colors.white30,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: index < 3 ? Colors.black : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      // ข้อมูลเด็ค
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deck.deckName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'โดย ${deck.creatorUsername}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // จำนวนการเข้าชม
                                      Column(
                                        children: [
                                          const Text(
                                            'เข้าชม',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            '${deck.viewCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === วิธีการสร้างกราฟรูปวงกลม ===
  Widget _buildPieChartSection(List<DeckModel> top5) {
    return Column(
      children: [
        const Text(
          "กราฟการเข้าชมทั้งหมด",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: top5.asMap().entries.map((entry) {
                int index = entry.key;
                DeckModel deck = entry.value;
                final colors = [
                  Colors.red[400],
                  Colors.blue[400],
                  Colors.green[400],
                  Colors.orange[400],
                  Colors.purple[400],
                ];
                final totalViews = top5.fold<int>(0, (sum, d) => sum + d.viewCount);
                final percentage = (deck.viewCount / totalViews * 100).toStringAsFixed(1);

                return PieChartSectionData(
                  value: deck.viewCount.toDouble(),
                  title: '$percentage%',
                  color: colors[index % colors.length],
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // คำอธิบายสีสำหรับแต่ละสำรับ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: top5.length,
            itemBuilder: (context, index) {
              final deck = top5[index];
              final colors = [
                Colors.red[400],
                Colors.blue[400],
                Colors.green[400],
                Colors.orange[400],
                Colors.purple[400],
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deck.deckName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${deck.viewCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../../core/routes/admin_routes.dart';
import '../../services/firestore_service.dart';

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  @override
  State<AdminReport> createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  // กำหนดเมนูที่กำลังเลือกอยู่เป็น Report
  String currentRoute = 'Report';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
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
      drawer: const AdminDrawer(currentRoute: 'Report'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "การรายงาน",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // ส่วนรายการ Report (ใช้ Expanded เพื่อให้เลื่อนดูได้ถ้ารายการยาว)
          Expanded(
            child: FutureBuilder(
              future: FirestoreService.getAllReports(),
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

                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีการรายงาน',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportItem(
                      reportId: report['id'],
                      deckId: report['deck_id'] ?? '',
                      reason: report['reason'] ?? 'ไม่ระบุ',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับแต่ละบล็อกรายงาน
  Widget _buildReportItem({
    required String reportId,
    required String deckId,
    required String reason,
  }) {
    return InkWell(
      onTap: () {
        // เมื่อกดจะไปที่หน้าละเอียด
        Navigator.pushNamed(
          context,
          AdminRoutes.adminReportDetail,
          arguments: {
            'reportId': reportId,
            'deckId': deckId,
            'reason': reason,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          // ทำเส้นขอบล่างให้ดูเหมือนในรูป
          border: Border(bottom: BorderSide(color: Color(0xFF13112B), width: 8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนรูปด้านซ้าย
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3AFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white30, size: 50),
            ),
            const SizedBox(width: 15),
            // ส่วนข้อมูลด้านขวา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "หมายเลขรายงาน : $reportId",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text("หมายเลขเด็ค : $deckId", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    "เหตุผล : $reason",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
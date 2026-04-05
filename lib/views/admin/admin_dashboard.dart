import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/admin_routes.dart';
import '../widgets/admin_drawer.dart';

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
            const SizedBox(height: 60),
            // ส่วนของกราฟ (Placeholder)
            _buildDonutChart(),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันวาดกราฟวงกลมจำลอง
  Widget _buildDonutChart() {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ในส่วนนี้ถ้าใช้ fl_chart จะเปลี่ยนเป็น PieChart(...) 
          // นี่คือตัวอย่างโครงสร้างวงกลมเบื้องต้น
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 40), // แทนที่ด้วยข้อมูลกราฟจริง
            ),
          ),
          // รูตรงกลางของ Donut
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'search/search_page.dart';
import 'widgets/custom_navbar.dart';
// import 'profile/profile_page.dart'; // เตรียมไว้

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // 1. รายชื่อหน้าจอทั้งหมดที่คุณมี (ใส่ไว้ที่เดียวจบ)
  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const Center(child: Text("Add Page", style: TextStyle(color: Colors.white))), // Mock
    const Center(child: Text("My Deck", style: TextStyle(color: Colors.white))),  // Mock
    const Center(child: Text("Profile", style: TextStyle(color: Colors.white))), // Mock
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. ใช้ IndexedStack เพื่อให้หน้าจอไม่ถูกทำลายทิ้งเวลาสลับ (จำค่าที่เลื่อนค้างไว้ได้)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // 3. ใส่ Navbar ไว้ที่นี่ "ที่เดียวในโลก"
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
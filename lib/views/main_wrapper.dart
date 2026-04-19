import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'search/search_page.dart';
import 'my_deck/my_deck_page.dart';
import 'widgets/custom_navbar.dart';
import 'package:project_flutter/views/create/manage_deck_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // 2. อัปเดตรายการหน้าจอให้ตรงกับ Index ของ Navbar
  late final List<Widget> _pages = [
    const HomePage(),   // Index 0
    const SearchPage(), // Index 1
    const ManageDeckPage(),
    const MyDeckPage(), // Index 3 (เปลี่ยนจาก Text เป็น MyDeckPage จริงๆ)
    const Center(child: Text("Profile", style: TextStyle(color: Colors.white))),  // Index 4 (รอทำ)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind BottomNavigationBar if we used it, but we use Stack for full control
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavbar(
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
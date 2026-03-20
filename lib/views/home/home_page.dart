import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_navbar.dart'; // เรียกใช้ Navbar ที่แยกออกมา

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDeckIndex = 0;
  int _selectedNavIndex = 0;
  final PageController _pageController = PageController();
  final List<String> _decks = List.generate(20, (index) => "DEC${index + 1}");

  void _onDeckSelected(int index) {
    setState(() => _selectedDeckIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Deck Selector แถบบน
            _buildDeckSelector(),
            // ส่วน PageView ไพ่ตรงกลาง
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _decks.length,
                onPageChanged: (index) {
                  setState(() => _selectedDeckIndex = index);
                },
                itemBuilder: (context, index) {
                  return _buildDeckCard(index);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedNavIndex,
        onItemSelected: (index) {
          setState(() => _selectedNavIndex = index);
          // จัดการ Navigation ระหว่างหน้าได้ที่นี่ในอนาคต
          if (index == 4) { } 
          // Navigator.pushNamed(context, AppRoutes.profile);
        },
      ),
    );
  }

  Widget _buildDeckSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _decks.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          bool isSelected = _selectedDeckIndex == index;
          return GestureDetector(
            onTap: () => _onDeckSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    _decks[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white30,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4), // แก้ไขจุดนี้แล้ว
                      height: 2,
                      width: 40,
                      color: Colors.white,
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeckCard(int index) {
    return Center(
      child: GestureDetector(
        onTap: () => print("Draw from Deck ${index + 1}"),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2140),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.style, size: 100, color: Colors.white10),
              const SizedBox(height: 20),
              Text(
                "DECK ${index + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
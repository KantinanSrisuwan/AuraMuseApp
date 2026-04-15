import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deck_detail_page.dart';
import 'deck_list_page.dart';

class DeckViewWrapper extends StatefulWidget {
  const DeckViewWrapper({super.key});

  @override
  State<DeckViewWrapper> createState() => _DeckViewWrapperState();
}

class _DeckViewWrapperState extends State<DeckViewWrapper> {
  // ใช้ PageController เพื่อคุมการเลื่อน
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // ดึง deckData จาก route arguments ที่ส่งมาจาก search_page.dart
    final deckData = ModalRoute.of(context)?.settings.arguments as QueryDocumentSnapshot?;

    return Scaffold(
      backgroundColor: Colors.black, // พื้นหลังดำสนิทเพื่อให้รอยต่อดูเนียน
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        // *** หัวใจสำคัญ: ทำให้ดีดล็อคหน้าแบบ TikTok ***
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()), 
        children: [
          DeckDetailPage(deckData: deckData),
          DeckListPage(deckData: deckData),
        ],
      ),
    );
  }
}
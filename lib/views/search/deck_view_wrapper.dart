import 'package:flutter/material.dart';
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
    // ดึง deckData จาก route arguments - รองรับทั้ง DocumentSnapshot และ QueryDocumentSnapshot
    final deckData = ModalRoute.of(context)?.settings.arguments as dynamic;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          DeckDetailPage(deckData: deckData),
          DeckListPage(deckData: deckData),
        ],
      ),
    );
  }
}

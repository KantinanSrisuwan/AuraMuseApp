import 'package:flutter/material.dart';
// 1. เพิ่ม Import MainWrapper (ตัวคุมหน้าจอหลัก)
import 'package:project_flutter/views/main_wrapper.dart'; 

// Import หน้าอื่นๆ (ใช้ Package Path จะไม่งงเรื่องจุดครับ)
import 'package:project_flutter/views/login/login_page.dart';
import 'package:project_flutter/views/login/register_page.dart';
import 'package:project_flutter/views/home/draw_result_page.dart';
import 'package:project_flutter/views/search/deck_view_wrapper.dart';
import 'package:project_flutter/views/my_deck/my_deck_page.dart';
import 'package:project_flutter/views/create/edit_deck_page.dart';
import 'package:project_flutter/views/create/manage_deck_page.dart';
import 'package:project_flutter/views/create/add_card_page.dart';





class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String mainWrapper = '/main'; // หน้าหลักหลัง Login
  static const String drawResult = '/draw_result';
  static const String deckDetail = '/deck_detail';
  static const String deckList = '/deck_list';
  static const String myDeck = '/my_deck';
  static const String manageDeck = '/manage_deck';
  static const String editDeck = '/edit_deck';
  static const String addCard = '/add_card';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      mainWrapper: (context) => const MainWrapper(),
      drawResult: (context) => const DrawResultPage(deckId: '', deckName: ''),
      deckDetail: (context) => const DeckViewWrapper(),
      myDeck: (context) => const MyDeckPage(),
      manageDeck: (context) => const ManageDeckPage(),
      editDeck: (context) => const EditDeckPage(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addCard:
        if (settings.arguments is Map) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AddCardPage(
              deckId: args['deckId'],
              cardId: args['cardId'],
              initialData: args['initialData'],
            ),
          );
        } else {
          final deckId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AddCardPage(deckId: deckId),
          );
        }
      default:
        return MaterialPageRoute(builder: (context) => const LoginPage());
    }
  }
}
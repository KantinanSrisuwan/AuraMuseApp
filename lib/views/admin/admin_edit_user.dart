import 'package:flutter/material.dart';

class AdminEditUserPage extends StatefulWidget {
  const AdminEditUserPage({super.key});
  @override State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage> {
  final uCont = TextEditingController();
  final pCont = TextEditingController();
  final eCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null) { uCont.text = args['username']; eCont.text = args['email']; }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(backgroundColor: Colors.transparent, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(children: [
          _field("Username", uCont), _field("Password", pCont, hide: true), _field("Email", eCont),
          const Spacer(),
          Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => Navigator.pop(context, {'username': uCont.text, 'email': eCont.text}), child: const Text("ยืนยัน"))),
            const SizedBox(width: 20),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () { uCont.clear(); pCont.clear(); eCont.clear(); }, child: const Text("ล้าง"))),
          ])
        ]),
      ),
    );
  }

  Widget _field(String l, TextEditingController c, {bool hide = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: Colors.white)), const SizedBox(height: 10), TextField(controller: c, obscureText: hide, decoration: InputDecoration(fillColor: Colors.white, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)))), const SizedBox(height: 20)]);
}
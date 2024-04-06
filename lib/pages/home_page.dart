import 'package:flutter/material.dart';
import 'package:skribbl_app/pages/create_room_page.dart';
import 'package:skribbl_app/pages/join_room_page.dart';
import 'package:skribbl_app/widgets/gradient_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.asset("assets/images/skribbl.png"),
          ),
          GradientButton(
              buttonText: "Create Room",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateRoomPage(),
                  ),
                );
              }),
          const SizedBox(height: 20),
          GradientButton(
              buttonText: "Join Room",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinRoomPage(),
                  ),
                );
              }),
        ],
      ),
    ));
  }
}

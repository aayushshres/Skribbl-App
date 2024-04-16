import 'package:flutter/material.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';
import 'package:skribbl_app/pages/paint_screen.dart';
import 'package:skribbl_app/widgets/gradient_button.dart';
import 'package:skribbl_app/widgets/gradient_textfield.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final nameController = TextEditingController();
  final roomNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void joinRoom() {
    if (formKey.currentState!.validate()) {
      Map<String, String> data = {
        "nickname": nameController.text,
        "name": roomNameController.text
      };

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: "joinRoom")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppPallete.gradient1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "JOIN ROOM",
                  style: TextStyle(
                    color: AppPallete.gradient1,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                GradientTextField(
                  hintText: "Enter Your Name",
                  controller: nameController,
                ),
                const SizedBox(height: 20),
                GradientTextField(
                  hintText: "Enter Room Name",
                  controller: roomNameController,
                ),
                const SizedBox(height: 40),
                GradientButton(
                    buttonText: "Join Room",
                    onPressed: () {
                      joinRoom();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

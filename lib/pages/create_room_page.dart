import 'package:flutter/material.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';
import 'package:skribbl_app/pages/waiting_page.dart';
import 'package:skribbl_app/widgets/dropdown_button.dart';
import 'package:skribbl_app/widgets/gradient_button.dart';
import 'package:skribbl_app/widgets/gradient_textfield.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final playerNameController = TextEditingController();
  final roomNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late String maxRoundValue;
  late String numberOfPlayers;

  @override
  void dispose() {
    playerNameController.dispose();
    roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: AppPallete.gradient1),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Create Room",
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.gradient1),
                  ),
                  const SizedBox(height: 30),
                  GradientTextField(
                    hintText: 'Enter your name',
                    controller: playerNameController,
                  ),
                  const SizedBox(height: 15),
                  GradientTextField(
                    hintText: 'Enter room name',
                    controller: roomNameController,
                  ),
                  const SizedBox(height: 15),
                  const DropdownWidget(
                    hintText: "Max Rounds",
                    itemList: ["3", "5", "7", "9"],
                  ),
                  const SizedBox(height: 15),
                  const DropdownWidget(
                    hintText: "Number of Players",
                    itemList: ["2", "3", "4", "5"],
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                      buttonText: "Create",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WaitingPage(),
                            ),
                          );
                        }
                      })
                ],
              )),
        ));
  }
}

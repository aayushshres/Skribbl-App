import 'package:flutter/material.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';
import 'package:skribbl_app/widgets/gradient_button.dart';
import 'package:skribbl_app/widgets/gradient_textfield.dart';
import 'paint_screen.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRoundsValue;
  late String? _roomSizeValue;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "occupancy": _maxRoundsValue!,
        "maxRounds": _roomSizeValue!
      };
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: 'createRoom')));
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CREATE ROOM",
                style: TextStyle(
                  color: AppPallete.gradient1,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              GradientTextField(
                controller: _nameController,
                hintText: "Enter Your name",
              ),
              const SizedBox(height: 20),
              GradientTextField(
                controller: _roomNameController,
                hintText: "Enter Room Name",
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                focusColor: AppPallete.transparentColor,
                dropdownColor: AppPallete.borderColor,
                items: <String>["2", "5", "10", "15"]
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: AppPallete.greyColor),
                        ),
                      ),
                    )
                    .toList(),
                hint: const Text('Select Max Rounds',
                    style: TextStyle(
                      color: AppPallete.greyColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                onChanged: (String? value) {
                  setState(() {
                    _maxRoundsValue = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                focusColor: AppPallete.transparentColor,
                dropdownColor: AppPallete.borderColor,
                items: <String>["2", "3", "4", "5", "6", "7", "8"]
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: AppPallete.greyColor),
                        ),
                      ),
                    )
                    .toList(),
                hint: const Text('Select Room Size',
                    style: TextStyle(
                      color: AppPallete.greyColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                onChanged: (String? value) {
                  setState(() {
                    _roomSizeValue = value;
                  });
                },
              ),
              const SizedBox(height: 40),
              GradientButton(
                  buttonText: "Create Room",
                  onPressed: () {
                    createRoom();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

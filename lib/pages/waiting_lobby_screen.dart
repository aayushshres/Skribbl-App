import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';

class WaitingLobbyScreen extends StatefulWidget {
  final int occupancy;
  final int noOfPlayers;
  final String lobbyName;
  final dynamic players;
  const WaitingLobbyScreen(
      {super.key,
      required this.occupancy,
      required this.noOfPlayers,
      required this.lobbyName,
      required this.players});

  @override
  State<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends State<WaitingLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Waiting for players to join....',
                  style: TextStyle(fontSize: 20))),
          const LinearProgressIndicator(
            color: AppPallete.gradient1,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ListView.builder(
              primary: true,
              shrinkWrap: true,
              itemCount: widget.noOfPlayers,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    "${index + 1}.",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  title: Text(
                    widget.players[index]['nickname'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
              onTap: () {
                // copy room code
                Clipboard.setData(ClipboardData(text: widget.lobbyName));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Copied!')));
              },
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      AppPallete.gradient1,
                      AppPallete.gradient2,
                      AppPallete.gradient3,
                      // AppPallete.gradient3,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Copy Room Name",
                        style: TextStyle(
                          color: AppPallete.backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.copy,
                        color: AppPallete.backgroundColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

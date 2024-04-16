// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';
import 'package:skribbl_app/models/my_custom_painter.dart';
import 'package:skribbl_app/models/touch_points.dart';
import 'package:skribbl_app/pages/final_leaderboard.dart';
import 'package:skribbl_app/pages/home_page.dart';
import 'package:skribbl_app/pages/waiting_lobby_screen.dart';
import 'package:skribbl_app/sidebar/player_scoreboard__drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  const PaintScreen({
    super.key,
    required this.data,
    required this.screenFrom,
  });

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late io.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = AppPallete.backgroundColor;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    connect();
    super.initState();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        _socket.emit("change-turn", dataOfRoom["name"]);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(
        const Text(
          "_",
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      );
    }
  }

  // socket io client connection
  void connect() {
    _socket = io.io("http://localhost:3000", <String, dynamic>{
      'transports': ['websocket'],
      'autoconnect': false
    });
    _socket.connect();

    if (widget.screenFrom == "createRoom") {
      _socket.emit("create-game", widget.data);
    } else {
      _socket.emit("join-game", widget.data);
    }

    // listen to socket
    _socket.onConnect((data) {
      _socket.on('updateRoom', (roomData) {
        setState(() {
          renderTextBlank(roomData["word"]);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData["players"].length; i++) {
          setState(() {
            scoreboard.add({
              "username": roomData["players"][i]["nickname"],
              "points": roomData["players"][i]["points"].toString(),
            });
          });
        }
      });

      _socket.on("notCorrectGame", (data) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false);
      });

      _socket.on("points", (point) {
        if (point["details"] != null) {
          setState(() {
            points.add(TouchPoints(
              points: Offset(
                (point["details"]["dx"]),
                (point["details"]["dy"]),
              ),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth,
            ));
          });
        }
      });

      _socket.on("color-change", (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });

      _socket.on("stroke-width", (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });
    });

    _socket.on("closeInput", (_) {
      _socket.emit("updateScore", widget.data["name"]);
      setState(() {
        isTextInputReadOnly = true;
      });
    });

    _socket.on("user-disconnected", (data) {
      scoreboard.clear();
      for (int i = 0; i < data["players"].length; i++) {
        setState(() {
          scoreboard.add({
            "username": data["players"][i]["nickname"],
            "points": data["players"][i]["points"].toString(),
          });
        });
      }
    });

    _socket.on("updateScore", (roomData) {
      scoreboard.clear();
      for (int i = 0; i < roomData["players"].length; i++) {
        setState(() {
          scoreboard.add({
            "username": roomData["players"][i]["nickname"],
            "points": roomData["players"][i]["points"].toString(),
          });
        });
      }
    });

    _socket.on("show-leaderboard", (roomPlayers) {
      scoreboard.clear();
      for (int i = 0; i < roomPlayers.length; i++) {
        setState(() {
          scoreboard.add({
            "username": roomPlayers[i]["nickname"],
            "points": roomPlayers[i]["points"].toString(),
          });
        });
        if (maxPoints < int.parse(scoreboard[i]["points"])) {
          winner = scoreboard[i]["username"];
          maxPoints = int.parse(scoreboard[i]["points"]);
        }
      }
      setState(() {
        _timer.cancel();
        isShowFinalLeaderboard = true;
      });
    });

    _socket.on("clear-screen", (data) {
      setState(() {
        points.clear();
      });
    });

    _socket.on("msg", (msgData) {
      setState(() {
        messages.add(msgData);
        guessedUserCtr = msgData["guessedUserCtr"];
      });
      if (guessedUserCtr == dataOfRoom["players"].length - 1) {
        _socket.emit("change-turn", dataOfRoom["name"]);
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 40,
        duration: const Duration(microseconds: 200),
        curve: Curves.easeInOut,
      );
    });

    _socket.on("change-turn", (data) {
      String oldWorld = dataOfRoom["word"];
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                dataOfRoom = data;
                renderTextBlank(data["word"]);
                isTextInputReadOnly = false;
                guessedUserCtr = 0;
                _start = 60;
                points.clear();
              });
              Navigator.of(context).pop();
              _timer.cancel();
              startTimer();
            });
            return AlertDialog(
              title: Center(
                child: Text("Word was $oldWorld"),
              ),
            );
          });
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Choose Color"),
                content: SingleChildScrollView(
                  child: BlockPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        String colorString = color.toString();
                        String valueString =
                            colorString.split('(0x')[1].split(')')[0];
                        Map map = {
                          "color": valueString,
                          "roomName": dataOfRoom["name"],
                        };
                        _socket.emit("color-change", map);
                      }),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              ));
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: PlayerScore(scoreboard),
      appBar: AppBar(
        title: Text(
          "Scribbl",
          style: GoogleFonts.pacifico(
              textStyle: const TextStyle(
            color: AppPallete.gradient1,
            fontSize: 30,
          )),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => scaffoldKey.currentState!.openDrawer(),
          icon: const Icon(
            Icons.menu,
            color: AppPallete.gradient1,
            size: 32,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CircularPercentIndicator(
              radius: 13,
              percent: (_start / 60 * 100) / 100,
              progressColor: AppPallete.gradient1,
              backgroundColor: AppPallete.gradient1.withAlpha(90),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
        ],
        surfaceTintColor: AppPallete.backgroundColor,
      ),
      body: dataOfRoom != null
          ? dataOfRoom["isJoin"] != true
              ? !isShowFinalLeaderboard
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: width,
                                  height: height * 0.40,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      _socket.emit("paint", {
                                        "details": {
                                          "dx": details.localPosition.dx,
                                          "dy": details.localPosition.dy,
                                        },
                                        "roomName": widget.data["name"],
                                      });
                                    },
                                    onPanStart: (details) {
                                      _socket.emit("paint", {
                                        "details": {
                                          "dx": details.localPosition.dx,
                                          "dy": details.localPosition.dy,
                                        },
                                        "roomName": widget.data["name"],
                                      });
                                    },
                                    onPanEnd: (details) {
                                      _socket.emit("paint", {
                                        "details": null,
                                        "roomName": widget.data["name"],
                                      });
                                    },
                                    child: SizedBox.expand(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        child: RepaintBoundary(
                                          child: CustomPaint(
                                            size: Size.infinite,
                                            painter: MyCustomPainter(
                                                pointsList: points),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        selectColor();
                                      },
                                      icon: const Icon(Icons.color_lens,
                                          color: AppPallete.gradient1),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        min: 1.0,
                                        max: 10.0,
                                        label: "Strokewidth $strokeWidth",
                                        value: strokeWidth,
                                        onChanged: (double value) {
                                          Map map = {
                                            "value": value,
                                            "roomName": dataOfRoom["name"],
                                          };
                                          _socket.emit("stroke-width", map);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _socket.emit(
                                            "clean-screen", dataOfRoom["name"]);
                                      },
                                      icon: const Icon(Icons.layers_clear,
                                          color: AppPallete.gradient1),
                                    ),
                                  ],
                                ),
                                dataOfRoom["turn"]["nickname"] !=
                                        widget.data["nickname"]
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: textBlankWidget,
                                      )
                                    : Center(
                                        child: Text(
                                          dataOfRoom["word"],
                                          style: const TextStyle(
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        var msg = messages[index].values;
                                        return ListTile(
                                          title: Text(
                                            msg.elementAt(0),
                                            style: const TextStyle(
                                              color: AppPallete.gradient1,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            msg.elementAt(1),
                                            style: const TextStyle(
                                              color: AppPallete.greyColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                )
                              ],
                            ),
                            dataOfRoom["turn"]["nickname"] !=
                                    widget.data["nickname"]
                                ? Positioned(
                                    bottom: 0,
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: TextField(
                                          readOnly: isTextInputReadOnly,
                                          autocorrect: false,
                                          controller: controller,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (value) {
                                            if (value.trim().isNotEmpty) {
                                              Map map = {
                                                "username":
                                                    widget.data["nickname"],
                                                "msg": value.trim(),
                                                "word": dataOfRoom["word"],
                                                "roomName": widget.data["name"],
                                                "guessedUserCtr":
                                                    guessedUserCtr,
                                                "totalTime": 60,
                                                "timeTaken": 60 - _start,
                                              };
                                              _socket.emit("msg", map);
                                              controller.clear();
                                            }
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "Your Guess",
                                            fillColor:
                                                AppPallete.backgroundColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    )
                  : FinalLeaderboard(scoreboard, winner)
              : WaitingLobbyScreen(
                  occupancy: dataOfRoom["occupancy"],
                  noOfPlayers: dataOfRoom["players"].length,
                  lobbyName: dataOfRoom["name"],
                  players: dataOfRoom["players"],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

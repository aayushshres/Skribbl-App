import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_app/core/theme/app_pallete.dart';
import 'package:skribbl_app/models/my_custom_painter.dart';
import 'package:skribbl_app/models/touch_points.dart';
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

  @override
  void initState() {
    connect();
    super.initState();
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
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          // start the timer
        }
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

    _socket.on("clear-screen", (data) {
      setState(() {
        points.clear();
      });
    });
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
        appBar: AppBar(),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  width: width,
                  height: height * 0.55,
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
                            painter: MyCustomPainter(pointsList: points),
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
                        _socket.emit("clean-screen", dataOfRoom["name"]);
                      },
                      icon: const Icon(Icons.layers_clear,
                          color: AppPallete.gradient1),
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: textBlankWidget,
                // ),
              ],
            ),
          ],
        ));
  }
}

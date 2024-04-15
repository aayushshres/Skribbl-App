import 'package:flutter/material.dart';
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

    // listen to socket
    _socket.onConnect((data) {});
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Paint Screen"),
      ),
    );
  }
}

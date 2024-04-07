import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    connect();
    print("test");
  }

  // socket io client connection
  void connect() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();

    // listen to socket
    _socket.onConnect((data) {
      print('connected');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}

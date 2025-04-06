import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class CameraContainer extends StatefulWidget {
  final dynamic state;

  CameraContainer({required this.state});

  @override
  _CameraContainerState createState() => _CameraContainerState();
}

class _CameraContainerState extends State<CameraContainer> {
  String _imagePath = 'assets/images/camera1.jpg'; // Default image
  late RawDatagramSocket _socket;

  @override
  void initState() {
    super.initState();
    _setupUdpListener();
  }

  void _setupUdpListener() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5006);
    _socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = _socket.receive();
        if (datagram != null) {
          String message = utf8.decode(datagram.data);
          setState(() {
            _imagePath = message;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1472,
      height: 828,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          _imagePath,
          width: 1472,
          height: 828,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'Resim yüklenemedi: $_imagePath',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }
}

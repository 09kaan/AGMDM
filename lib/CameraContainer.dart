import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CameraContainer extends StatefulWidget {
  final dynamic state;

  const CameraContainer({Key? key, required this.state}) : super(key: key);

  @override
  CameraContainerState createState() => CameraContainerState();
}

class CameraContainerState extends State<CameraContainer> {
  Uint8List? _lastImage;
  bool _isConnected = false;
  RawDatagramSocket? _socket;
  Timer? _connectionTimer;
  DateTime? _lastDataTime;

  @override
  void initState() {
    super.initState();
    _setupUdpListener();
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _isConnected = _lastDataTime != null &&
              DateTime.now().difference(_lastDataTime!) < const Duration(seconds: 2);
        });
      }
    });
  }

  void _setupUdpListener() async {
    if (_socket != null) {
      _socket!.close();
      _socket = null;
    }

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5011);
      print('Kamera UDP dinleyici başlatıldı (Port: 5011)');

      _socket!.broadcastEnabled = false;
      
      _socket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            _handleData();
          }
        },
        onError: (error) {
          print('Kamera dinleme hatası: $error');
          _resetConnection();
        },
        onDone: () {
          print('Kamera bağlantısı kapandı');
          _resetConnection();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Kamera bağlantı hatası: $e');
      _resetConnection();
      
      if (mounted) {
        Future.delayed(const Duration(seconds: 3), _setupUdpListener);
      }
    }
  }

  void _handleData() {
    try {
      final datagram = _socket?.receive();
      if (datagram != null) {
        final message = String.fromCharCodes(datagram.data);
        final data = json.decode(message);
        
        if (mounted) {
          setState(() {
            _lastImage = base64Decode(data['image']);
            _lastDataTime = DateTime.now();
          });
        }
      }
    } catch (e) {
      print('Veri işleme hatası: $e');
    }
  }

  void _resetConnection() {
    if (mounted) {
      setState(() {
        _lastDataTime = null;
        _lastImage = null; // Son görüntüyü temizle
      });
    }
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1472,
      height: 828,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _lastImage != null && _isConnected
            ? Image.memory(
                _lastImage!,
                fit: BoxFit.fill,
                width: 1472,
                height: 828,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamera bağlantısı bekleniyor...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Log1 extends StatefulWidget {
  final dynamic state;

  Log1({Key? key, required this.state}) : super(key: key);

  @override
  Log1State createState() => Log1State();
}

class Log1State extends State<Log1> {
  final List<String> _logs = [];
  RawDatagramSocket? _socket;
  final int _port = 5010;

  @override
  void initState() {
    super.initState();
    _setupUdpListener();
  }

  void _setupUdpListener() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
      print('Log dinleyici başlatıldı. Port: $_port');
      print('Dinlenen IP: ${InternetAddress.anyIPv4.address}');

      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket!.receive();
          if (datagram != null) {
            String message = utf8.decode(datagram.data);
            print('Alınan log: $message');
            print('Gönderen IP: ${datagram.address.address}');
            print('Gönderen Port: ${datagram.port}');
            addLog(message);
          }
        }
      });
    } catch (e) {
      print('UDP bağlantı hatası: $e');
      print('Stack trace: ${StackTrace.current}');
      Future.delayed(Duration(seconds: 3), () {
        print('Yeniden bağlanmaya çalışılıyor...');
        _setupUdpListener();
      });
    }
  }

  void addLog(String log) {
    setState(() {
      String timeStamp = DateTime.now().toString().substring(11, 19);
      _logs.insert(0, "$timeStamp - $log");
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 630,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DATA LOG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      _logs[index],
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontFamily: 'Courier',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }
}

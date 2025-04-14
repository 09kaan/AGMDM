import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class SignalStrengthContainer extends StatefulWidget {
  final dynamic state;

  const SignalStrengthContainer({Key? key, required this.state}) : super(key: key);

  @override
  SignalStrengthContainerState createState() => SignalStrengthContainerState();
}

class SignalStrengthContainerState extends State<SignalStrengthContainer> {
  int _signalStrength = 0;
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
          if (_lastDataTime != null &&
              DateTime.now().difference(_lastDataTime!) > const Duration(seconds: 2)) {
            _signalStrength = 0;
          }
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
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5014);
      print('Sinyal gücü dinleyici başlatıldı (Port: 5014)');

      _socket!.broadcastEnabled = false;
      
      _socket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            _handleData();
          }
        },
        onError: (error) {
          print('Sinyal gücü dinleme hatası: $error');
          _resetConnection();
        },
        onDone: () {
          print('Sinyal gücü bağlantısı kapandı');
          _resetConnection();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Sinyal gücü bağlantı hatası: $e');
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
            _lastDataTime = DateTime.now();
            _signalStrength = data['signal_strength'];
          });
        }
      }
    } catch (e) {
      print('Sinyal gücü veri işleme hatası: $e');
    }
  }

  void _resetConnection() {
    if (mounted) {
      setState(() {
        _lastDataTime = null;
        _signalStrength = 0;
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
    // Sinyal gücüne göre durum ve renk belirleme
    String status;
    Color signalColor;
    if (_signalStrength > -50) {
      status = 'Excellent';
      signalColor = Colors.green;
    } else if (_signalStrength > -60) {
      status = 'Good';
      signalColor = Colors.blue;
    } else if (_signalStrength > -70) {
      status = 'Fair';
      signalColor = Colors.yellow;
    } else {
      status = 'Weak';
      signalColor = Colors.red;
    }

    return SizedBox(
      width: 220,
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Dış halka
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: signalColor.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                // Orta halka
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status != 'Weak' ? signalColor.withOpacity(0.6) : signalColor.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                // İç halka
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status == 'Excellent' || status == 'Good' ? signalColor : signalColor.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                // En iç halka
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status == 'Excellent' ? signalColor : signalColor.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                // Merkez nokta
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: signalColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: TextStyle(
                color: signalColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_signalStrength} dBm',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

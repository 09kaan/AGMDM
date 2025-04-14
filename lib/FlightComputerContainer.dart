import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

class FlightComputer extends StatefulWidget {
  final dynamic state;

  const FlightComputer({Key? key, required this.state}) : super(key: key);

  @override
  FlightComputerState createState() => FlightComputerState();
}

class FlightComputerState extends State<FlightComputer> {
  double _pitch = 0.0;
  double _roll = 0.0;
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
    // Eğer zaten bir soket varsa kapat
    if (_socket != null) {
      _socket!.close();
      _socket = null;
    }

    try {
      // UDP soketini oluştur ve 5012 portunu dinle (Log dinleyiciden farklı port)
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5012);
      print('Flight Computer UDP dinleyici başlatıldı (Port: 5012)');

      // Soket ayarlarını yap
      _socket!.broadcastEnabled = false;
      
      // Veri dinlemeyi başlat
      _socket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            _handleData();
          }
        },
        onError: (error) {
          print('Flight Computer dinleme hatası: $error');
          _resetConnection();
        },
        onDone: () {
          print('Flight Computer bağlantısı kapandı');
          _resetConnection();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Flight Computer bağlantı hatası: $e');
      _resetConnection();
      
      // 3 saniye sonra tekrar dene
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
            _pitch = data['pitch']?.toDouble() ?? 0.0;
            _roll = data['roll']?.toDouble() ?? 0.0;
            _lastDataTime = DateTime.now();
          });
          
          print('Veri alındı: P=${_pitch.toStringAsFixed(1)}°, R=${_roll.toStringAsFixed(1)}°');
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
        _pitch = 0.0;
        _roll = 0.0;
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
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey[850]!,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(220, 220),
              painter: HorizonPainter(pitch: _pitch, roll: _roll),
            ),
            CustomPaint(
              size: const Size(220, 220),
              painter: PitchLinesPainter(pitch: _pitch, roll: _roll),
            ),
            // Heading göstergesi
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110,
              child: CustomPaint(
                size: const Size(220, 110),
                painter: HeadingPainter(roll: _roll),
              ),
            ),
            // Merkez gösterge
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.yellow,
                          width: 2,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 60,
                        height: 2,
                        color: Colors.yellow,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 2,
                        height: 60,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Durum göstergesi
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green[700] : Colors.red[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _isConnected ? 'BAĞLI' : 'BAĞLI DEĞİL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Değerler
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'P:${_pitch.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'R:${_roll.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizonPainter extends CustomPainter {
  final double pitch;
  final double roll;

  HorizonPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll * pi / 180);

    // Gökyüzü
    final skyPaint = Paint()..color = const Color(0xFF0099FF);
    canvas.drawRect(
      Rect.fromLTWH(-radius, -radius - (pitch * radius / 90), radius * 2, radius * 2),
      skyPaint,
    );

    // Yeryüzü
    final groundPaint = Paint()..color = const Color(0xFF855723);
    canvas.drawRect(
      Rect.fromLTWH(-radius, 0 - (pitch * radius / 90), radius * 2, radius * 2),
      groundPaint,
    );

    // Ufuk çizgisi
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(-radius, 0 - (pitch * radius / 90)),
      Offset(radius, 0 - (pitch * radius / 90)),
      horizonPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(HorizonPainter oldDelegate) =>
      oldDelegate.pitch != pitch || oldDelegate.roll != roll;
}

class PitchLinesPainter extends CustomPainter {
  final double pitch;
  final double roll;

  PitchLinesPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll * pi / 180);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Pitch çizgileri
    for (var i = -20; i <= 20; i += 5) {
      if (i == 0) continue; // Ufuk çizgisini atla

      final y = (i - pitch) * radius / 90;
      final width = (i % 10 == 0) ? 40.0 : 20.0;

      if (y.abs() < radius) {
        canvas.drawLine(
          Offset(-width / 2, y),
          Offset(width / 2, y),
          paint,
        );

        // Derece değeri
        if (i % 10 == 0) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: i.abs().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(width / 2 + 5, y - textPainter.height / 2),
          );
          textPainter.paint(
            canvas,
            Offset(-width / 2 - textPainter.width - 5, y - textPainter.height / 2),
          );
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PitchLinesPainter oldDelegate) =>
      oldDelegate.pitch != pitch || oldDelegate.roll != roll;
}

class HeadingPainter extends CustomPainter {
  final double roll;

  HeadingPainter({required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.45;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-roll * pi / 180);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Üst yarım daire çizimi
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawArc(rect, -pi, 0, false, paint);

    // Açı işaretleri (özel dereceler)
    final angles = [-60, -45, -30, -10, 0, 10, 30, 45, 60];
    for (var angle in angles) {
      final angleRad = angle * pi / 180;
      
      // Çizgi uzunluğunu belirle
      double markerLength = 10.0;
      
      // Çizgi başlangıç ve bitiş noktaları
      final startX = radius * sin(angleRad);
      final startY = -radius * cos(angleRad);
      final endX = (radius - markerLength) * sin(angleRad);
      final endY = -(radius - markerLength) * cos(angleRad);
      
      // Çizgileri çiz
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Sayıları göster
      final textPainter = TextPainter(
        text: TextSpan(
          text: angle.abs().toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Metni çizginin yanına yerleştir
      final textRadius = radius - 15;
      final textX = textRadius * sin(angleRad);
      final textY = -textRadius * cos(angleRad);
      
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(angleRad);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(HeadingPainter oldDelegate) => oldDelegate.roll != roll;
} 
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as Math;

class Compasscontainer extends StatefulWidget {
  final dynamic state;

  Compasscontainer({required this.state});

  @override
  _CompasscontainerState createState() => _CompasscontainerState();
}

class _CompasscontainerState extends State<Compasscontainer> {
  double _compassAngle = 0.0;
  late RawDatagramSocket _socket;

  @override
  void initState() {
    super.initState();
    _setupUdpListener();
  }

  void _setupUdpListener() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5005);
    _socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = _socket.receive();
        if (datagram != null) {
          String message = utf8.decode(datagram.data);
          setState(() {
            _compassAngle = double.tryParse(message) ?? 0.0;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: CompassPainter(_compassAngle * (3.141592653589793 / 180)),
      ),
    );
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }
}

class CompassPainter extends CustomPainter {
  final double angle;

  CompassPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the outer circle
    paint.color = Colors.grey;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    // Draw dashed concentric circles
    paint.color = Colors.white.withOpacity(0.5);
    paint.strokeWidth = 1.0;
    for (double i = 0.12; i < 0.4; i += 0.13) {
      final Path path = Path();
      for (double angle = 0; angle < 360; angle += 5) {
        final double radian = angle * (Math.pi / 180);
        final double x = size.width / 2 + size.width * i * Math.cos(radian);
        final double y = size.height / 2 + size.width * i * Math.sin(radian);
        if (angle % 10 == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw the needle
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;
    final Path needlePath = Path();
    needlePath.moveTo(size.width / 2, size.height / 2 );
    needlePath.lineTo(size.width / 2 - 15, size.height / 2 + 10); // arka oklar
    needlePath.lineTo(size.width / 2, size.height / 2 - 23); // uzunluk
    needlePath.lineTo(size.width / 2 + 15, size.height / 2 + 10); // arka oklar
    needlePath.close();
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2); // centeri belirliyo
    canvas.rotate(angle);
    canvas.translate(-size.width / 2, -size.height / 2); // centeri belirliyo
    canvas.drawPath(needlePath, paint);
    canvas.restore();

    // Draw direction indicators with circles
    final double circleRadius = 10.0;
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width / 2, 2), circleRadius, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height - 2), circleRadius, paint);
    canvas.drawCircle(Offset(size.width - 2, size.height / 2), circleRadius, paint);
    canvas.drawCircle(Offset(2, size.height / 2), circleRadius, paint);

    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 2), circleRadius, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height - 2), circleRadius, paint);
    canvas.drawCircle(Offset(size.width - 2, size.height / 2), circleRadius, paint);
    canvas.drawCircle(Offset(2, size.height / 2), circleRadius, paint);

    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: 'N',
      style: TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, -6));

    textPainter.text = TextSpan(
      text: 'S',
      style: TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height - 10));

    textPainter.text = TextSpan(
      text: 'E',
      style: TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 5, size.height / 2 - textPainter.height / 2));

    textPainter.text = TextSpan(
      text: 'W',
      style: TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-4, size.height / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

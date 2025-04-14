import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Log2 extends StatefulWidget {
  final dynamic state;

  Log2({required this.state});

  @override
  _Log2State createState() => _Log2State();
}

class _Log2State extends State<Log2> {
  bool _isActive = false;
  String _currentMode = 'AUTONOMOUS';
  RawDatagramSocket? _socket;
  final String _targetIp = '192.168.31.164';
  final int _targetPort = 5009;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 150,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CONTROLS başlığı
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              'CONTROLS',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Safety butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: _isActive ? Colors.red : Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleState,
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(
                          'SAFETY:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          _isActive ? 'ARMED' : 'DISARMED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Mode göstergesi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleMode,
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'MODE:',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              _currentMode,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.swap_horiz,
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleState() {
    setState(() {
      _isActive = !_isActive;
      String logMessage = _isActive
          ? "Safety protocol deactive"
          : "Safety protocol active";
      widget.state.addLog(logMessage);
    });
  }

  void _toggleMode() {
    setState(() {
      _currentMode = _currentMode == 'AUTONOMOUS' ? 'GUIDED' : 'AUTONOMOUS';
    });
  }
}
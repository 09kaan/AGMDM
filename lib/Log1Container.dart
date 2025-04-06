import 'package:flutter/material.dart';

class Log1 {
  final dynamic state;

  Log1({required this.state});

  Widget buildLog1WidgeT(BuildContext context) {
    return Container(
      width: 400,
      height: 630,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        shape: BoxShape.rectangle,
      ),
      alignment: const AlignmentDirectional(0, 0),
    );
    //imported global state from UI.dart you can use this imported state to change the state of the widget
  }
}

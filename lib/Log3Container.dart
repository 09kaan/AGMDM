import 'package:flutter/material.dart';

class Log3 extends StatelessWidget {
  final dynamic state;

  const Log3({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        shape: BoxShape.rectangle,
      ),
      alignment: const AlignmentDirectional(0, 0),
    );
    //imported global state from UI.dart you can use this imported state to change the state of the widget
    // You can access state properties here
    // Example: child: Text(state.someProperty)
    //imported global state from UI.dart you can use this imported state to change the state of the widget
  }
}

import 'package:flutter/material.dart';

class Log2 {
  final dynamic state;
  
  Log2({required this.state});
  
  Widget buildLog2Widget(BuildContext context) {
    return Container(
      width: 400,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        shape: BoxShape.rectangle,
      ),
      alignment: AlignmentDirectional(0, 0),
    );
      // You can access state properties here
      // Example: child: Text(state.someProperty)
      //imported global state from UI.dart you can use this imported state to change the state of the widget
  }
}
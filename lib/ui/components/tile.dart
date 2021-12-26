import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  const Tile(
      {Key? key, required this.color, required this.value, required this.size})
      : super(key: key);

  final int value;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: size,
        width: size,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          color: color,
          elevation: 3,
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ));
  }
}

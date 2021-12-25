import 'package:flutter/material.dart';

class Grid extends StatelessWidget {
  const Grid(
      {Key? key,
      this.backgroundColor = Colors.brown,
      this.strokeColor = Colors.black})
      : super(key: key);
  final Color backgroundColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      return CustomPaint(
        size: Size(boxConstraints.maxWidth, boxConstraints.maxWidth),
        painter: GridPainter(
            backgroundColor: backgroundColor, strokeColor: strokeColor),
      );
    });
  }
}

class GridPainter extends CustomPainter {
  GridPainter({required this.backgroundColor, required this.strokeColor});
  final Color backgroundColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    Rect background = Offset.zero & size;
    Paint line_paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRect(background, Paint()..color = backgroundColor);
    // canvas.drawRect(
    //     background,
    //     line_paint);
    double lineSpace = size.width / 4;
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(Offset(i * lineSpace, 0),
          Offset(i * lineSpace, size.height), line_paint);
      canvas.drawLine(Offset(0, i * lineSpace),
          Offset(size.width, i * lineSpace), line_paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

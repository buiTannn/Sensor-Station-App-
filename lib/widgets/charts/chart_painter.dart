import 'package:flutter/material.dart';
import 'dart:math';

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final String unit;

  ChartPainter(this.data, this.lineColor, this.unit);

  @override
  void paint(Canvas canvas, Size size) {
    double minVal = data.reduce(min);
    double maxVal = data.reduce(max);
    double range = maxVal - minVal;
    if (range == 0) range = 1;

    final chartArea = Rect.fromLTRB(30, 10, size.width - 10, size.height - 20);

    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = chartArea.top + (chartArea.height / 4) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        axisPaint,
      );

      double value = maxVal - (range / 4) * i;
      final textSpan = TextSpan(
        text: value.toStringAsFixed(0),
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }

    DateTime now = DateTime.now();
    for (int i = 0; i < data.length; i += 2) {
      double x = chartArea.left + (chartArea.width / (data.length - 1)) * i;
      canvas.drawLine(
        Offset(x, chartArea.bottom),
        Offset(x, chartArea.bottom + 5),
        axisPaint,
      );

      DateTime timePoint = now.subtract(
        Duration(seconds: (data.length - 1 - i) * 3),
      );
      String timeLabel =
          '${timePoint.hour.toString().padLeft(2, '0')}:${timePoint.minute.toString().padLeft(2, '0')}';

      final textSpan = TextSpan(
        text: timeLabel,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 8),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 12, chartArea.bottom + 6));
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chartArea);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      double x = chartArea.left + (chartArea.width / (data.length - 1)) * i;
      double y =
          chartArea.bottom - ((data[i] - minVal) / range) * chartArea.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartArea.bottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(chartArea.right, chartArea.bottom);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      double x = chartArea.left + (chartArea.width / (data.length - 1)) * i;
      double y =
          chartArea.bottom - ((data[i] - minVal) / range) * chartArea.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

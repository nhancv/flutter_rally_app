import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:rally/rally/models/accounts.dart';

class CircleChartPainter extends CustomPainter {
  const CircleChartPainter({
    this.accountSet,
    this.strokeWidth,
  });

  final AccountSet accountSet;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double accountsTotal = accountSet.total;
    final Rect rect =
        EdgeInsets.all(strokeWidth * 0.5).deflateRect(Offset.zero & size);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    double start = -math.pi / 2.0;
    final double dividerSweep =
        ((math.pi * 2) / size.longestSide) * strokeWidth * 0.25;
    final double totalSweep = math.pi * 2 - (dividerSweep * accountSet.length);
    for (int i = 0; i < accountSet.length; i++) {
      final double sweep = totalSweep * (accountSet[i].balance / accountsTotal);
      paint.color = accountSet[i].color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + dividerSweep;
    }
  }

  @override
  bool shouldRepaint(CircleChartPainter oldDelegate) =>
      oldDelegate.accountSet != accountSet;
}

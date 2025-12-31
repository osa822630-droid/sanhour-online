import 'package:flutter/material.dart';

class AnalyticsCharts extends StatelessWidget {
  const AnalyticsCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BarChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final double maxValue;
  final Color barColor;
  final double barWidth;
  final double spacing;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.maxValue,
    this.barColor = Colors.blue,
    this.barWidth = 20,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final height = (item.value / maxValue) * 150;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: barWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  item.value.toString(),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final double maxValue;
  final Color lineColor;
  final bool showPoints;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.maxValue,
    this.lineColor = Colors.blue,
    this.showPoints = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: LineChartPainter(
          data: data,
          maxValue: maxValue,
          lineColor: lineColor,
          showPoints: showPoints,
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final List<ChartData> data;
  final double size;

  const PieChartWidget({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PieChartPainter(data: data),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    this.color = Colors.blue,
  });
}

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;
  final Color lineColor;
  final bool showPoints;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.lineColor,
    required this.showPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    if (data.length < 2) return;

    final points = _calculatePoints(size);

    // رسم الخط
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // رسم النقاط
    if (showPoints) {
      for (final point in points) {
        canvas.drawCircle(point, 3, pointPaint);
      }
    }
  }

  List<Offset> _calculatePoints(Size size) {
    final points = <Offset>[];
    final widthStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * widthStep;
      final y = size.height - (data[i].value / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    return points;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    var startAngle = -90.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (final item in data) {
      final sweepAngle = (item.value / total) * 360;
      
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle * (3.14159 / 180), 
                    sweepAngle * (3.14159 / 180), true, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final String? description;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.chart,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }
}
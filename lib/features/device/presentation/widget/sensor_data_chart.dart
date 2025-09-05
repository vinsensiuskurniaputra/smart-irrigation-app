import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class SensorDataChart extends StatelessWidget {
  final String title;
  final List<double> dataPoints;
  final String unit;
  final double minValue;
  final double maxValue;
  final List<String> labels;

  const SensorDataChart({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme 
                ? AppColors.charcoal.withOpacity(0.2)
                : AppColors.gray.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Chart
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(
                dataPoints: dataPoints,
                minValue: minValue,
                maxValue: maxValue,
                isDarkTheme: isDarkTheme,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // X-axis labels
          SizedBox(
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((label) => Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Min', _formatValue(dataPoints.reduce((a, b) => a < b ? a : b)), isDarkTheme),
              _buildStatItem('Avg', _formatValue(_calculateAverage(dataPoints)), isDarkTheme),
              _buildStatItem('Max', _formatValue(dataPoints.reduce((a, b) => a > b ? a : b)), isDarkTheme),
              _buildStatItem('Now', _formatValue(dataPoints.last), isDarkTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDarkTheme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? AppColors.darkText : AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  // Factory constructor for moisture chart
  static SensorDataChart moisture({
    List<double> dataPoints = const [65, 62, 68, 75, 72, 70, 73],
  }) {
    return SensorDataChart(
      title: 'Soil Moisture',
      dataPoints: dataPoints,
      unit: '%',
      minValue: 0,
      maxValue: 100,
      labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );
  }

  // Factory constructor for temperature chart
  static SensorDataChart temperature({
    List<double> dataPoints = const [24.5, 25.0, 26.2, 25.8, 24.3, 23.9, 25.5],
  }) {
    return SensorDataChart(
      title: 'Temperature',
      dataPoints: dataPoints,
      unit: '°C',
      minValue: 15,
      maxValue: 35,
      labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );
  }

  // Factory constructor for humidity chart
  static SensorDataChart humidity({
    List<double> dataPoints = const [60, 58, 65, 70, 68, 72, 67],
  }) {
    return SensorDataChart(
      title: 'Humidity',
      dataPoints: dataPoints,
      unit: '%',
      minValue: 0,
      maxValue: 100,
      labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double minValue;
  final double maxValue;
  final bool isDarkTheme;

  _ChartPainter({
    required this.dataPoints,
    required this.minValue,
    required this.maxValue,
    required this.isDarkTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double chartPadding = 16;
    final double drawingWidth = width - (chartPadding * 2);
    final double drawingHeight = height - (chartPadding * 2);
    
    // Draw grid lines
    final paint = Paint()
      ..color = isDarkTheme ? AppColors.darkDivider : AppColors.platinum
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Horizontal grid lines (5 lines)
    final gridLineCount = 5;
    for (var i = 0; i <= gridLineCount; i++) {
      final y = chartPadding + (drawingHeight / gridLineCount * i);
      canvas.drawLine(
        Offset(chartPadding, y),
        Offset(width - chartPadding, y),
        paint,
      );
    }
    
    // Draw line chart
    if (dataPoints.length < 2) return;
    
    final linePaint = Paint()
      ..color = isDarkTheme ? AppColors.silver : AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final pointWidth = drawingWidth / (dataPoints.length - 1);
    
    // Normalize data points to fit the chart height
    double normalize(double value) {
      return chartPadding + drawingHeight - 
          ((value - minValue) / (maxValue - minValue)) * drawingHeight;
    }
    
    // Start path at first point
    path.moveTo(
      chartPadding,
      normalize(dataPoints[0]),
    );
    
    // Add lines to each subsequent point
    for (var i = 1; i < dataPoints.length; i++) {
      path.lineTo(
        chartPadding + (pointWidth * i),
        normalize(dataPoints[i]),
      );
    }
    
    // Draw the line path
    canvas.drawPath(path, linePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = isDarkTheme ? AppColors.darkText : AppColors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    
    final pointStrokePaint = Paint()
      ..color = isDarkTheme ? AppColors.silver : AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (var i = 0; i < dataPoints.length; i++) {
      final x = chartPadding + (pointWidth * i);
      final y = normalize(dataPoints[i]);
      
      // Draw point circle
      canvas.drawCircle(Offset(x, y), 4, pointStrokePaint);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

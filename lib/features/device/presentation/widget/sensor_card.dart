import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class SensorCard extends StatelessWidget {
  final String sensorType;
  final String value;
  final String unit;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.icon,
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
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDarkTheme ? AppColors.silver : AppColors.slate,
              ),
              const SizedBox(width: 8),
              Text(
                _formatSensorType(sensorType),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSensorType(String type) {
    // Convert snake_case to Title Case
    final words = type.split('_');
    final formattedWords = words.map((word) => 
      word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase());
    return formattedWords.join(' ');
  }

  static SensorCard soilMoisture(double value) {
    return SensorCard(
      sensorType: 'soil_moisture',
      value: value.toString(),
      unit: '%',
      icon: Icons.water_drop_outlined,
    );
  }

  static SensorCard temperature(double value) {
    return SensorCard(
      sensorType: 'temperature',
      value: value.toString(),
      unit: '°C',
      icon: Icons.thermostat_outlined,
    );
  }

  static SensorCard humidity(double value) {
    return SensorCard(
      sensorType: 'humidity',
      value: value.toString(),
      unit: '%',
      icon: Icons.water_outlined,
    );
  }
}

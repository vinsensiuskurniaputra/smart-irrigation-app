import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/home/data/models/device_model.dart';

class DeviceStatsWidget extends StatelessWidget {
  final List<DeviceModel> devices;
  final bool showLabels;

  const DeviceStatsWidget({
    super.key,
    required this.devices,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onlineCount = devices.where((device) => device.isOnline).length;
    final offlineCount = devices.length - onlineCount;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Online',
              onlineCount.toString(),
              Icons.check_circle_outline,
              isDarkTheme ? AppColors.silver : AppColors.primary,
              isDarkTheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          ),
          Expanded(
            child: _buildStatItem(
              'Offline',
              offlineCount.toString(),
              Icons.radio_button_unchecked,
              isDarkTheme ? AppColors.slate : AppColors.gray,
              isDarkTheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          ),
          Expanded(
            child: _buildStatItem(
              'Total',
              devices.length.toString(),
              Icons.device_hub_outlined,
              isDarkTheme ? AppColors.darkTextSecondary : AppColors.secondary,
              isDarkTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDarkTheme,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: iconColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? AppColors.darkText : AppColors.primary,
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
            ),
          ),
        ],
      ],
    );
  }
}
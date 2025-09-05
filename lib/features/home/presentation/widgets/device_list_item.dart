import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/home/data/models/device_model.dart';

class DeviceListItem extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback? onTap;

  const DeviceListItem({
    super.key,
    required this.device,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isOnline = device.isOnline;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Device Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkTheme 
                        ? AppColors.darkSurface 
                        : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDeviceIcon(),
                    size: 24,
                    color: isDarkTheme 
                        ? AppColors.silver 
                        : AppColors.slate,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Device Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device Name
                      Text(
                        device.deviceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkTheme 
                              ? AppColors.darkText 
                              : AppColors.primary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Device Code
                      Text(
                        device.deviceCode,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDarkTheme 
                              ? AppColors.darkTextSecondary 
                              : AppColors.gray,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Indicator
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(isOnline, isDarkTheme),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusIndicatorColor(isOnline, isDarkTheme),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            device.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusTextColor(isOnline, isDarkTheme),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    // You can customize this based on device type or name
    final deviceName = device.deviceName.toLowerCase();
    
    if (deviceName.contains('greenhouse')) {
      return Icons.home_outlined;
    } else if (deviceName.contains('sensor')) {
      return Icons.sensors_outlined;
    } else if (deviceName.contains('pump')) {
      return Icons.water_outlined;
    } else if (deviceName.contains('valve')) {
      return Icons.tune_outlined;
    } else {
      return Icons.device_hub_outlined;
    }
  }

  Color _getStatusBackgroundColor(bool isOnline, bool isDarkTheme) {
    if (isDarkTheme) {
      return isOnline 
          ? AppColors.darkSurface 
          : AppColors.charcoal;
    } else {
      return isOnline 
          ? AppColors.smoke 
          : AppColors.lightGray;
    }
  }

  Color _getStatusIndicatorColor(bool isOnline, bool isDarkTheme) {
    if (isDarkTheme) {
      return isOnline 
          ? AppColors.silver 
          : AppColors.slate;
    } else {
      return isOnline 
          ? AppColors.primary 
          : AppColors.gray;
    }
  }

  Color _getStatusTextColor(bool isOnline, bool isDarkTheme) {
    if (isDarkTheme) {
      return isOnline 
          ? AppColors.darkText 
          : AppColors.darkTextSecondary;
    } else {
      return isOnline 
          ? AppColors.primary 
          : AppColors.gray;
    }
  }
}
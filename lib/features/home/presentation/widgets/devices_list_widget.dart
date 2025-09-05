import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';
import 'package:smart_irrigation_app/features/home/data/models/device_model.dart';
import 'package:smart_irrigation_app/features/home/presentation/widgets/device_list_item.dart';

class DevicesListWidget extends StatelessWidget {
  final List<DeviceModel> devices;
  final Function(DeviceModel)? onDeviceTap;
  final bool showHeader;
  final String? headerTitle;

  const DevicesListWidget({
    super.key,
    required this.devices,
    this.onDeviceTap,
    this.showHeader = true,
    this.headerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerTitle ?? 'Your Devices',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme 
                            ? AppColors.darkText 
                            : AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${devices.length} device${devices.length != 1 ? 's' : ''} connected',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme 
                            ? AppColors.darkTextSecondary 
                            : AppColors.gray,
                      ),
                    ),
                  ],
                ),
                
                // Status Summary
                _buildStatusSummary(isDarkTheme),
              ],
            ),
          ),
        ],
        
        // Devices List
        if (devices.isEmpty)
          _buildEmptyState(isDarkTheme)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return DeviceListItem(
                  device: device,
                  onTap: () => onDeviceTap?.call(device),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSummary(bool isDarkTheme) {
    final onlineCount = devices.where((device) => device.isOnline).length;
    final offlineCount = devices.length - onlineCount;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkCard : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Online indicator
          if (onlineCount > 0) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDarkTheme ? AppColors.silver : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$onlineCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? AppColors.darkText : AppColors.primary,
              ),
            ),
          ],
          
          if (onlineCount > 0 && offlineCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 1,
                height: 12,
                color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
              ),
            ),
          
          // Offline indicator
          if (offlineCount > 0) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDarkTheme ? AppColors.slate : AppColors.gray,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$offlineCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDarkTheme ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.device_hub_outlined,
              size: 48,
              color: isDarkTheme ? AppColors.slate : AppColors.gray,
            ),
            const SizedBox(height: 16),
            Text(
              'No Devices Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? AppColors.darkText : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect your irrigation devices to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension widget for quick device stats
class DeviceStatsRow extends StatelessWidget {
  final List<DeviceModel> devices;

  const DeviceStatsRow({
    super.key,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onlineCount = devices.where((device) => device.isOnline).length;
    final offlineCount = devices.length - onlineCount;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Online',
              onlineCount.toString(),
              Icons.check_circle_outline,
              isDarkTheme ? AppColors.silver : AppColors.primary,
              isDarkTheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Offline',
              offlineCount.toString(),
              Icons.radio_button_unchecked,
              isDarkTheme ? AppColors.slate : AppColors.gray,
              isDarkTheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDarkTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? AppColors.darkText : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}
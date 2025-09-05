import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

enum ActuatorMode { manual, auto }

class ActuatorControlCard extends StatelessWidget {
  final String actuatorName;
  final String type;
  final String pinNumber;
  final bool isActive;
  final Function(bool) onToggle;
  final ActuatorMode mode;
  final Function(ActuatorMode)? onModeChanged;

  const ActuatorControlCard({
    super.key,
    required this.actuatorName,
    required this.type,
    required this.pinNumber,
    required this.isActive,
    required this.onToggle,
    this.mode = ActuatorMode.manual,
    this.onModeChanged,
  });

  IconData _getActuatorIcon() {
    switch (type.toLowerCase()) {
      case 'pump':
        return Icons.water;
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'fan':
        return Icons.air;
      case 'valve':
        return Icons.tune;
      default:
        return Icons.settings;
    }
  }

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
        children: [
          Row(
            children: [
              // Icon for the actuator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActuatorIcon(),
                  size: 24,
                  color: isActive 
                      ? isDarkTheme ? AppColors.darkText : AppColors.primary 
                      : isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Actuator info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actuatorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Pin: $pinNumber',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? isDarkTheme ? AppColors.darkSurface : AppColors.lightGray
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isActive ? 'ON' : 'OFF',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Toggle switch
              Switch(
                value: isActive,
                onChanged: mode == ActuatorMode.manual ? onToggle : null,
                activeColor: isDarkTheme ? AppColors.silver : AppColors.primary,
                activeTrackColor: isDarkTheme ? AppColors.slate : AppColors.primary_500,
              ),
            ],
          ),
          
          // Mode selector
          if (onModeChanged != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: 14,
                      color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Control Mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    ),
                  ],
                ),
                _buildModeSelector(isDarkTheme),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeSelector(bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Manual mode
          GestureDetector(
            onTap: onModeChanged != null ? () => onModeChanged!(ActuatorMode.manual) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mode == ActuatorMode.manual
                    ? isDarkTheme ? AppColors.darkCard : AppColors.white
                    : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: mode == ActuatorMode.manual
                        ? isDarkTheme ? AppColors.darkText : AppColors.primary
                        : isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Manual',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: mode == ActuatorMode.manual ? FontWeight.bold : FontWeight.normal,
                      color: mode == ActuatorMode.manual
                          ? isDarkTheme ? AppColors.darkText : AppColors.primary
                          : isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 24,
            color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          ),
          
          // Auto mode
          GestureDetector(
            onTap: onModeChanged != null ? () => onModeChanged!(ActuatorMode.auto) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mode == ActuatorMode.auto
                    ? isDarkTheme ? AppColors.darkCard : AppColors.white
                    : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_mode,
                    size: 14,
                    color: mode == ActuatorMode.auto
                        ? isDarkTheme ? AppColors.darkText : AppColors.primary
                        : isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Auto',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: mode == ActuatorMode.auto ? FontWeight.bold : FontWeight.normal,
                      color: mode == ActuatorMode.auto
                          ? isDarkTheme ? AppColors.darkText : AppColors.primary
                          : isDarkTheme ? AppColors.darkTextSecondary : AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
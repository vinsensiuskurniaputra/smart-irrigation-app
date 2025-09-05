import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class PlantInfoCard extends StatelessWidget {
  final String plantName;
  final String imageUrl;
  final Map<String, dynamic> irrigationRules;
  final VoidCallback onPredictPlant;

  const PlantInfoCard({
    super.key,
    required this.plantName,
    required this.imageUrl,
    required this.irrigationRules,
    required this.onPredictPlant,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
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
          // Plant info header
          Row(
            children: [
              // Plant image or placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? Icon(
                        Icons.eco_outlined,
                        size: 30,
                        color: isDarkTheme 
                            ? AppColors.darkTextSecondary 
                            : AppColors.gray,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Plant name and predict button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plant',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkTheme 
                            ? AppColors.darkTextSecondary 
                            : AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plantName.isNotEmpty 
                          ? plantName.substring(0, 1).toUpperCase() + plantName.substring(1) 
                          : 'Not Set',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? AppColors.darkText : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Predict button
              ElevatedButton.icon(
                onPressed: onPredictPlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
                  foregroundColor: isDarkTheme ? AppColors.darkText : AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
                    ),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Predict', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Irrigation rules
          Text(
            'Irrigation Rules',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? AppColors.darkText : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Rule cards grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildRuleCard(
                'Soil Moisture',
                '${irrigationRules['min_moisture']}% - ${irrigationRules['max_moisture']}%',
                Icons.water_drop_outlined,
                isDarkTheme,
              ),
              _buildRuleCard(
                'Temperature',
                '${irrigationRules['preferred_temp']}°C',
                Icons.thermostat_outlined,
                isDarkTheme,
              ),
              _buildRuleCard(
                'Humidity',
                '${irrigationRules['preferred_humidity']}%',
                Icons.water_outlined,
                isDarkTheme,
              ),
              _buildRuleCard(
                'Plant Type',
                irrigationRules['plant_name'],
                Icons.eco_outlined,
                isDarkTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(
    String label,
    String value,
    IconData icon,
    bool isDarkTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColors.darkSurface : AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkTheme ? AppColors.darkDivider : AppColors.platinum,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDarkTheme 
                    ? AppColors.darkTextSecondary 
                    : AppColors.gray,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkTheme 
                      ? AppColors.darkTextSecondary 
                      : AppColors.gray,
                ),
              ),
            ],
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/core/config/theme/app_colors.dart';

class AppTheme {
  static final mainTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.primary),
      bodyMedium: TextStyle(color: AppColors.primary),
      titleLarge: TextStyle(color: AppColors.primary),
      titleMedium: TextStyle(color: AppColors.primary),
      titleSmall: TextStyle(color: AppColors.primary_500),
    ),
    cardColor: AppColors.white,
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: AppColors.primary,
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((
        Set<MaterialState> states,
      ) {
        return IconThemeData(
          color:
              states.contains(MaterialState.selected)
                  ? AppColors.primary
                  : Colors.grey,
        );
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
        Set<MaterialState> states,
      ) {
        return TextStyle(
          color:
              states.contains(MaterialState.selected)
                  ? AppColors.primary
                  : Colors.grey,
        );
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Poppins',
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkDivider,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
      titleLarge: TextStyle(color: AppColors.darkText),
      titleMedium: TextStyle(color: AppColors.darkText),
      titleSmall: TextStyle(color: AppColors.darkTextSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: IconThemeData(color: AppColors.darkText),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: AppColors.darkIndicatorNav,
      backgroundColor: AppColors.darkBackgroundNav,
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((
        Set<MaterialState> states,
      ) {
        return IconThemeData(
          color: states.contains(MaterialState.selected)
              ? AppColors.primaryDark
              : AppColors.darkTextSecondary,
        );
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
        Set<MaterialState> states,
      ) {
        return TextStyle(
          color: states.contains(MaterialState.selected)
              ? AppColors.primaryDark
              : AppColors.darkTextSecondary,
        );
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    ),
  );
}

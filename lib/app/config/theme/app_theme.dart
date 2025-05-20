import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  //  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: AppColors.textBarColor,
      ),
      appBarTheme:  AppBarTheme(
          centerTitle: true,
          // backgroundColor: AppColors.buttonColor,
          titleTextStyle: TextStyle(
            color: AppColors.textBarColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          actionsIconTheme: IconThemeData(
            color: AppColors.whiteColor,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textBarColor,
          )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textBarColor,
          textStyle: const TextStyle(
            color: Colors.white,
            // fontSize: MediaQuery.of(Get.context!).size.width > 720
            //     ? AppDimens.font22
            //     : AppDimens.font16,
          ),
          // foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:  TextStyle(
            color: AppColors.greyColor, fontSize: 14, fontWeight: FontWeight.w200),
        errorStyle:  TextStyle(color: AppColors.redColor),
        fillColor: AppColors.blackColor.withOpacity(0.1),
        filled: true,
        isDense: true,

        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.textBarColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.textBarColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.textBarColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.redColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
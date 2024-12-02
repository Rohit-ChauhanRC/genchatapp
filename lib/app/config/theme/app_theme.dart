import 'package:flutter/material.dart';
import 'package:genchatapp/app/constants/colors.dart';

class AppTheme {
  //  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: appBarColor,
      ),
      appBarTheme: const AppBarTheme(
          centerTitle: true,
          // backgroundColor: AppColors.buttonColor,
          titleTextStyle: TextStyle(
            color: textBarColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          actionsIconTheme: IconThemeData(
            color: whiteColor,
          ),
          iconTheme: IconThemeData(
            color: textBarColor,
          )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textBarColor,
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
        hintStyle: const TextStyle(
            color: greyColor, fontSize: 14, fontWeight: FontWeight.w200),
        errorStyle: const TextStyle(color: redColor),
        fillColor: whiteColor,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: textBarColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: textBarColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: textBarColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: redColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:genchatapp/app/config/theme/app_colors.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;

  const GradientContainer({
    super.key,
    required this.child,
  });


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: child,
    );
  }
}
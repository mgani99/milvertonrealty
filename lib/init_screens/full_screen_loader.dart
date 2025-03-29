import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:milvertonrealty/utils/constants.dart';

class FullScreenLoader {
  static Future openLoadinDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context1) => Container(
        height: double.infinity,
        width: double.infinity,
        color: primaryColor,
        padding: const EdgeInsets.all(40),
        child: Center(
          child: LottieBuilder.asset(
            AnimationConstants.loading,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  static stopLoadin(BuildContext context) {
    Navigator.of(context).pop();
  }
}

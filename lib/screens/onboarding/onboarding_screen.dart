import 'package:flutter/material.dart';
import 'package:sunuTask/core/constants/app_colors.dart';
import 'package:sunuTask/core/constants/app_strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Ecran Onboarding',
          style: TextStyle(
              fontSize: 24,
              color: AppColors.textPrimary
          ),
        ),
      ),
    );
  }

}
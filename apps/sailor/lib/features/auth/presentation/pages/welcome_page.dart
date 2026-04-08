import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// Welcome page — first screen of the onboarding flow.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo / Branding
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.highlight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.sailing,
                  size: 44,
                  color: AppColors.textOnHighlight,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Sailor',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              Text(
                'Decentralised event protocol\nfor the sailing community',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
              ),

              const Spacer(flex: 4),

              // Sign in with Bluesky (AT Protocol)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.atLogin),
                  icon: const Icon(Icons.cloud_outlined),
                  label: const Text('Sign in with Bluesky'),
                ),
              ),
              const SizedBox(height: 12),

              // Create local identity (offline-only)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.createIdentity),
                  child: const Text('Use Offline Only'),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

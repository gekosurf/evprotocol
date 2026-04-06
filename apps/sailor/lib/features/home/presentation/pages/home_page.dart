import 'package:flutter/material.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// Home page — post-login landing screen.
///
/// Placeholder for now, will be replaced with event feed.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sailor'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Color(0xFFFFD600),
            ),
            SizedBox(height: 16),
            Text(
              'Identity Created',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: 8),
            Text(
              'You\'re in. More features coming soon.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

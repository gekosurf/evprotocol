import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/tracking/presentation/providers/tracking_providers.dart';

/// Tracking page — start/stop GPS tracking for an event.
///
/// Phase 3b: shows tracking controls + buffered position count.
/// Future: map view with flutter_map + OpenStreetMap tiles.
class TrackingPage extends ConsumerWidget {
  final String eventAtUri;
  final String eventName;

  const TrackingPage({
    super.key,
    required this.eventAtUri,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(isTrackingProvider);
    final pendingCount = ref.watch(pendingPositionsProvider);
    final isTracking = trackingState.when(
      data: (v) => v,
      loading: () => false,
      error: (_, _) => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Event name
              Text(
                eventName,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Yacht Position Tracking',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 40),

              // Tracking status indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTracking
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.surfaceBg,
                  border: Border.all(
                    color: isTracking ? AppColors.success : AppColors.border,
                    width: isTracking ? 3 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTracking ? Icons.sailing : Icons.sailing_outlined,
                      size: 48,
                      color: isTracking
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTracking ? 'LIVE' : 'READY',
                      style: AppTextStyles.label.copyWith(
                        color: isTracking
                            ? AppColors.success
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buffered count
              if (isTracking) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload_outlined,
                          size: 18, color: AppColors.highlight),
                      const SizedBox(width: 8),
                      Text(
                        '$pendingCount points buffered',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Positions flush to PDS every 60s',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],

              const Spacer(),

              // Privacy notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 20, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tracking only when you tap Start. '
                        'No ambient or background tracking.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Start/Stop button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isTracking ? AppColors.error : AppColors.highlight,
                  ),
                  onPressed: () async {
                    final service = ref.read(positionServiceProvider);
                    if (isTracking) {
                      await service.stopTracking();
                    } else {
                      await service.startTracking(eventAtUri);
                    }
                  },
                  icon: Icon(
                    isTracking ? Icons.stop : Icons.play_arrow,
                    color: isTracking
                        ? Colors.white
                        : AppColors.textOnHighlight,
                  ),
                  label: Text(
                    isTracking ? 'Stop Tracking' : 'Start Tracking',
                    style: TextStyle(
                      color: isTracking
                          ? Colors.white
                          : AppColors.textOnHighlight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/events/presentation/providers/event_providers.dart';

/// Derive participant DIDs from event creator + RSVP attendees.
/// Used by photo and tracking pages to know whose PDS to scan.
final eventParticipantDidsProvider =
    FutureProvider.family<List<String>, EvDhtKey>((ref, eventKey) async {
  final repo = ref.read(eventRepositoryProvider);
  final event = await repo.getEvent(eventKey);
  final rsvps = await repo.getEventRsvps(eventKey);

  final dids = <String>{};
  if (event != null) dids.add(event.creatorPubkey.value);
  for (final rsvp in rsvps) {
    dids.add(rsvp.attendeePubkey.value);
  }
  return dids.toList();
});

/// Shows the list of RSVPs for an event.
class RsvpListSection extends ConsumerWidget {
  final EvEvent event;

  const RsvpListSection({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpsFuture = ref.watch(eventRsvpsProvider(event.dhtKey!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, size: 18, color: AppColors.highlight),
            const SizedBox(width: 8),
            const Text('ATTENDEES', style: AppTextStyles.label),
            const SizedBox(width: 8),
            rsvpsFuture.when(
              data: (rsvps) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.highlightMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${rsvps.length}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.highlight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              loading: () => const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        rsvpsFuture.when(
          data: (rsvps) {
            if (rsvps.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.group_outlined,
                        size: 32, color: AppColors.textTertiary),
                    SizedBox(height: 8),
                    Text(
                      'No RSVPs yet — be the first!',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: rsvps.map((rsvp) => _RsvpTile(rsvp: rsvp)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => const Text(
            'Could not load RSVPs',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }
}

/// Provider that fetches RSVPs for a specific event.
final eventRsvpsProvider =
    FutureProvider.autoDispose.family<List<EvRsvp>, EvDhtKey>((ref, eventKey) async {
  final repo = ref.read(eventRepositoryProvider);
  return repo.getEventRsvps(eventKey);
});

class _RsvpTile extends StatelessWidget {
  final EvRsvp rsvp;
  const _RsvpTile({required this.rsvp});

  @override
  Widget build(BuildContext context) {
    final statusIcon = _statusIcon(rsvp.status);
    final statusColor = _statusColor(rsvp.status);
    final did = rsvp.attendeePubkey.value;
    // Show truncated DID as display name (Phase 4: resolve handles)
    final displayName = did.length > 20
        ? '${did.substring(0, 12)}…${did.substring(did.length - 6)}'
        : did;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 18,
            backgroundColor: statusColor.withValues(alpha: 0.2),
            child: Icon(statusIcon, size: 18, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(rsvp.status),
                  style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
          if (rsvp.guestCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${rsvp.guestCount}',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _statusIcon(EvRsvpStatus status) {
    switch (status) {
      case EvRsvpStatus.confirmed:
        return Icons.check_circle;
      case EvRsvpStatus.pending:
        return Icons.schedule;
      case EvRsvpStatus.waitlisted:
        return Icons.hourglass_empty;
      case EvRsvpStatus.cancelled:
        return Icons.cancel;
      case EvRsvpStatus.declined:
        return Icons.cancel_outlined;
    }
  }

  Color _statusColor(EvRsvpStatus status) {
    switch (status) {
      case EvRsvpStatus.confirmed:
        return AppColors.success;
      case EvRsvpStatus.pending:
        return AppColors.warning;
      case EvRsvpStatus.waitlisted:
        return AppColors.info;
      case EvRsvpStatus.cancelled:
      case EvRsvpStatus.declined:
        return AppColors.error;
    }
  }

  String _statusLabel(EvRsvpStatus status) {
    switch (status) {
      case EvRsvpStatus.confirmed:
        return 'Going';
      case EvRsvpStatus.pending:
        return 'Interested';
      case EvRsvpStatus.waitlisted:
        return 'Waitlisted';
      case EvRsvpStatus.cancelled:
        return 'Cancelled';
      case EvRsvpStatus.declined:
        return 'Declined';
    }
  }
}

import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/discover/presentation/providers/discover_providers.dart';
import 'package:sailor/features/events/presentation/providers/event_providers.dart';
import 'package:sailor/features/events/presentation/widgets/rsvp_bottom_sheet.dart';
import 'package:sailor/features/events/presentation/widgets/rsvp_list_section.dart';

/// Event detail page — full event information.
class EventDetailPage extends ConsumerWidget {
  final EvEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhtKeyVal = event.dhtKey?.value;
    final freshEventAsync = dhtKeyVal != null ? ref.watch(eventDetailProvider(dhtKeyVal)) : null;
    final displayEvent = freshEventAsync?.value ?? event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Tags
            if (displayEvent.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: displayEvent.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.highlightMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.highlight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(displayEvent.name, style: AppTextStyles.h1),
            const SizedBox(height: 16),

            // Date & time
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'When',
              value: _formatDateRange(displayEvent),
            ),
            const SizedBox(height: 12),

            // Location
            if (displayEvent.location != null) ...[
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Where',
                value: displayEvent.location!.name ?? 'Unknown',
                subtitle: displayEvent.location!.address,
              ),
              const SizedBox(height: 12),
            ],

            // Attendees
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Going',
              value: '${displayEvent.rsvpCount} attending',
            ),
            const SizedBox(height: 12),

            // Visibility
            _InfoRow(
              icon: displayEvent.visibility == EvEventVisibility.private_
                  ? Icons.lock_outline
                  : Icons.public,
              label: 'Visibility',
              value: displayEvent.visibility == EvEventVisibility.private_
                  ? 'Invite Only'
                  : 'Public',
            ),

            // Ticketing
            if (displayEvent.ticketing != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.confirmation_number_outlined,
                label: 'Tickets',
                value: _formatTicketing(displayEvent),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Description
            if (displayEvent.description != null) ...[
              const Text('ABOUT', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(displayEvent.description!, style: AppTextStyles.body),
              const SizedBox(height: 24),
            ],

            // Attendee list
            RsvpListSection(event: displayEvent),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // RSVP button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.surfaceBg,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (sheetContext) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                        top: 24,
                      ),
                      child: RsvpBottomSheet(
                        event: displayEvent,
                        onRsvp: (status) async {
                          // Persist the RSVP via use case
                          final rsvpUseCase = ref.read(rsvpToEventUseCaseProvider);
                          await rsvpUseCase(
                            eventDhtKey: displayEvent.dhtKey!,
                            status: status,
                          );
                          // Refresh event lists and the single event detail view
                          ref.invalidate(discoverEventsProvider);
                          ref.invalidate(myEventsProvider);
                          if (displayEvent.dhtKey != null) {
                            ref.invalidate(eventDetailProvider(displayEvent.dhtKey!.value));
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('RSVP recorded as ${status.name} ✓'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
                child: const Text('RSVP — Going'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final atUri = displayEvent.dhtKey?.value ?? '';
                  if (atUri.startsWith('at://')) {
                    Clipboard.setData(ClipboardData(text: atUri));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AT URI copied to clipboard'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event not yet synced — share after sync'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Event'),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Sailing-specific actions
            const Text('SAILING', style: AppTextStyles.label),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final key = displayEvent.dhtKey?.value ?? '';
                      context.push(
                        '${AppRoutes.tracking}/${Uri.encodeComponent(key)}',
                        extra: {
                          'eventAtUri': key,
                          'eventName': displayEvent.name,
                        },
                      );
                    },
                    icon: const Icon(Icons.sailing, size: 18),
                    label: const Text('Track'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final key = displayEvent.dhtKey?.value ?? '';
                      context.push(
                        '${AppRoutes.eventPhotos}/${Uri.encodeComponent(key)}',
                        extra: {
                          'eventAtUri': key,
                          'eventName': displayEvent.name,
                          'participantDids': <String>[],
                        },
                      );
                    },
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Photos'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(EvEvent displayEvent) {
    final start = DateTime.parse(displayEvent.startAt.toIso8601());
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = '${start.day} ${months[start.month - 1]} ${start.year}';
    final time =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    if (displayEvent.endAt != null) {
      final end = DateTime.parse(displayEvent.endAt!.toIso8601());
      final endTime =
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      return '$day · $time – $endTime';
    }
    return '$day · $time';
  }

  String _formatTicketing(EvEvent displayEvent) {
    final t = displayEvent.ticketing!;
    if (t.model == EvTicketModel.free) return 'Free';
    if (t.tiers.isEmpty) return 'Ticketed';
    final tier = t.tiers.first;
    final dollars = (tier.priceMinor / 100).toStringAsFixed(0);
    return '\$$dollars ${t.currency} — ${tier.name}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.highlight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.body),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

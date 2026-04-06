import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter/material.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/events/presentation/widgets/rsvp_bottom_sheet.dart';

/// Event detail page — full event information.
class EventDetailPage extends StatelessWidget {
  final EvEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
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
            if (event.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: event.tags.map((tag) {
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
            Text(event.name, style: AppTextStyles.h1),
            const SizedBox(height: 16),

            // Date & time
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'When',
              value: _formatDateRange(),
            ),
            const SizedBox(height: 12),

            // Location
            if (event.location != null) ...[
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Where',
                value: event.location!.name ?? 'Unknown',
                subtitle: event.location!.address,
              ),
              const SizedBox(height: 12),
            ],

            // Attendees
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Going',
              value: '${event.rsvpCount} attending',
            ),
            const SizedBox(height: 12),

            // Visibility
            _InfoRow(
              icon: event.visibility == EvEventVisibility.private_
                  ? Icons.lock_outline
                  : Icons.public,
              label: 'Visibility',
              value: event.visibility == EvEventVisibility.private_
                  ? 'Invite Only'
                  : 'Public',
            ),

            // Ticketing
            if (event.ticketing != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.confirmation_number_outlined,
                label: 'Tickets',
                value: _formatTicketing(),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Description
            if (event.description != null) ...[
              const Text('ABOUT', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(event.description!, style: AppTextStyles.body),
              const SizedBox(height: 24),
            ],

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
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        top: 24,
                      ),
                      child: RsvpBottomSheet(
                        event: event,
                        onRsvp: (status) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('RSVP recorded as ${status.name} ✓'),
                              backgroundColor: AppColors.success,
                            ),
                          );
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
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Share via DHT link
                },
                child: const Text('Share Event'),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _formatDateRange() {
    final start = DateTime.parse(event.startAt.toIso8601());
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = '${start.day} ${months[start.month - 1]} ${start.year}';
    final time =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    if (event.endAt != null) {
      final end = DateTime.parse(event.endAt!.toIso8601());
      final endTime =
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      return '$day · $time – $endTime';
    }
    return '$day · $time';
  }

  String _formatTicketing() {
    final t = event.ticketing!;
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

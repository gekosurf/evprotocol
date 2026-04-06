import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter/material.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// A compact event card for the event list.
class EventCard extends StatelessWidget {
  final EvEvent event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags row
            if (event.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                children: event.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.highlightMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.highlight,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            // Title
            Text(
              event.name,
              style: AppTextStyles.h3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Description
            if (event.description != null) ...[
              Text(
                event.description!,
                style: AppTextStyles.bodySecondary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
            ],

            // Info row
            Row(
              children: [
                // Date
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(event.startAt),
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(width: 16),

                // Location
                if (event.location != null) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!.name ?? 'Unknown',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // RSVP count
                const SizedBox(width: 8),
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${event.rsvpCount}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),

            // Ticketing badge
            if (event.ticketing != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.highlight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.highlight.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _formatPrice(event.ticketing!),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.highlight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(EvTimestamp ts) {
    final dt = DateTime.parse(ts.toIso8601());
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} · $hour:$minute';
  }

  String _formatPrice(EvTicketing ticketing) {
    if (ticketing.model == EvTicketModel.free) return 'FREE';
    if (ticketing.tiers.isEmpty) return 'TICKETED';
    final tier = ticketing.tiers.first;
    final dollars = (tier.priceMinor / 100).toStringAsFixed(0);
    return '\$$dollars ${ticketing.currency}';
  }
}

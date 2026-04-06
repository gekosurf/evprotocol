import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter/material.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// RSVP bottom sheet — lets the user select their attendance status.
class RsvpBottomSheet extends StatefulWidget {
  final EvEvent event;
  final ValueChanged<EvRsvpStatus> onRsvp;

  const RsvpBottomSheet({super.key, required this.event, required this.onRsvp});

  @override
  State<RsvpBottomSheet> createState() => _RsvpBottomSheetState();
}

class _RsvpBottomSheetState extends State<RsvpBottomSheet> {
  EvRsvpStatus? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RSVP', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            widget.event.name,
            style: AppTextStyles.bodySecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Status options
          _RsvpOption(
            icon: Icons.check_circle,
            label: 'Going',
            subtitle: 'Count me in',
            color: AppColors.success,
            isSelected: _selected == EvRsvpStatus.confirmed,
            onTap: () => setState(() => _selected = EvRsvpStatus.confirmed),
          ),
          const SizedBox(height: 8),
          _RsvpOption(
            icon: Icons.help_outline,
            label: 'Maybe',
            subtitle: 'I\'ll try to make it',
            color: AppColors.warning,
            isSelected: _selected == EvRsvpStatus.pending,
            onTap: () => setState(() => _selected = EvRsvpStatus.pending),
          ),
          const SizedBox(height: 8),
          _RsvpOption(
            icon: Icons.cancel_outlined,
            label: 'Not Going',
            subtitle: 'Can\'t make it this time',
            color: AppColors.error,
            isSelected: _selected == EvRsvpStatus.cancelled,
            onTap: () => setState(() => _selected = EvRsvpStatus.cancelled),
          ),

          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected != null
                  ? () {
                      widget.onRsvp(_selected!);
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(
                _selected != null ? 'Confirm RSVP' : 'Select a status',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RsvpOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

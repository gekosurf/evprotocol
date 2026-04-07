import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/discover/presentation/providers/search_providers.dart';

/// Debounced search bar widget.
class EventSearchBar extends ConsumerStatefulWidget {
  const EventSearchBar({super.key});

  @override
  ConsumerState<EventSearchBar> createState() => _EventSearchBarState();
}

class _EventSearchBarState extends ConsumerState<EventSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).update(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Search events…',
          hintStyle: AppTextStyles.bodySecondary,
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.highlight, width: 1.5),
          ),
        ),
      ),
    );
  }
}

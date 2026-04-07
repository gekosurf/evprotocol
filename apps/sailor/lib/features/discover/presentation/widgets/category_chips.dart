import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/discover/presentation/providers/discover_providers.dart';
import 'package:sailor/features/discover/presentation/providers/search_providers.dart';

/// Horizontally scrollable category filter chips.
///
/// Categories are auto-derived from event data via [categoriesProvider].
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    'All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selectedCategory == null
                          ? AppColors.textOnHighlight
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: selectedCategory == null,
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).clear();
                  },
                  selectedColor: AppColors.highlight,
                  backgroundColor: AppColors.surfaceBg,
                  side: BorderSide(
                    color: selectedCategory == null
                        ? AppColors.highlight
                        : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Dynamic category chips
              ...categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _capitalize(cat),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.textOnHighlight
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .select(isSelected ? null : cat);
                    },
                    selectedColor: AppColors.highlight,
                    backgroundColor: AppColors.surfaceBg,
                    side: BorderSide(
                      color: isSelected ? AppColors.highlight : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

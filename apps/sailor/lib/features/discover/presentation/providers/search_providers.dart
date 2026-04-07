import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current search query text (shared between tabs).
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

/// Currently selected category filter (null = all).
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
  SelectedCategoryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;

  void clear() => state = null;
}

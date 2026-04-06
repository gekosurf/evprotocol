import '../core/ev_dht_key.dart';
import '../core/ev_timestamp.dart';

/// A search result from any tier of the search architecture.
///
/// Schema: `ev.search.index`
class EvSearchResult {
  /// DHT key of the event.
  final EvDhtKey eventDhtKey;

  /// Event title.
  final String title;

  /// Event description snippet.
  final String? descriptionSnippet;

  /// Event start time.
  final EvTimestamp startAt;

  /// Event category.
  final String? category;

  /// Location name.
  final String? locationName;

  /// Latitude.
  final double? latitude;

  /// Longitude.
  final double? longitude;

  /// Distance from search origin in kilometres (if geo-search).
  final double? distanceKm;

  /// Search relevance score (0.0 to 1.0, Tier 3 only).
  final double? relevanceScore;

  /// Which search tier returned this result.
  final int searchTier;

  /// RSVP count (approximate).
  final int rsvpCount;

  /// Group DHT key (if group event).
  final EvDhtKey? groupDhtKey;

  /// Tags.
  final List<String> tags;

  const EvSearchResult({
    required this.eventDhtKey,
    required this.title,
    this.descriptionSnippet,
    required this.startAt,
    this.category,
    this.locationName,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.relevanceScore,
    required this.searchTier,
    this.rsvpCount = 0,
    this.groupDhtKey,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'eventDhtKey': eventDhtKey.toString(),
        'title': title,
        if (descriptionSnippet != null)
          'descriptionSnippet': descriptionSnippet,
        'startAt': startAt.toIso8601(),
        if (category != null) 'category': category,
        if (locationName != null) 'locationName': locationName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (relevanceScore != null) 'relevanceScore': relevanceScore,
        'searchTier': searchTier,
        'rsvpCount': rsvpCount,
        if (groupDhtKey != null) 'groupDhtKey': groupDhtKey.toString(),
        if (tags.isNotEmpty) 'tags': tags,
      };

  factory EvSearchResult.fromJson(Map<String, dynamic> json) {
    return EvSearchResult(
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      title: json['title'] as String,
      descriptionSnippet: json['descriptionSnippet'] as String?,
      startAt: EvTimestamp.parse(json['startAt'] as String),
      category: json['category'] as String?,
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble(),
      searchTier: json['searchTier'] as int,
      rsvpCount: json['rsvpCount'] as int? ?? 0,
      groupDhtKey: json['groupDhtKey'] != null
          ? EvDhtKey(json['groupDhtKey'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}

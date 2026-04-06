import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';
import '../media/ev_media_reference.dart';
import '../payment/ev_payment_intent.dart';

/// An event record in the EV Protocol.
///
/// Schema: `ev.event.record`
///
/// Events are multi-writer DHT records. The organiser owns subkey 0 (metadata).
/// Additional subkeys can be allocated to venue, artists, and co-organisers.
class EvEvent {
  /// DHT key for this event.
  final EvDhtKey? dhtKey;

  /// Public key of the event creator/organiser.
  final EvPubkey creatorPubkey;

  /// Event title.
  final String name;

  /// Event description (supports markdown).
  final String? description;

  /// Event start time.
  final EvTimestamp startAt;

  /// Event end time.
  final EvTimestamp? endAt;

  /// Location details.
  final EvEventLocation? location;

  /// Event category.
  final String? category;

  /// Tags for discovery.
  final List<String> tags;

  /// Cover image reference.
  final EvMediaReference? coverImageRef;

  /// Ticketing configuration.
  final EvTicketing? ticketing;

  /// Event visibility.
  final EvEventVisibility visibility;

  /// Maximum attendee capacity.
  final int? maxCapacity;

  /// Current RSVP count (approximate, updated periodically).
  final int rsvpCount;

  /// Group this event belongs to (e.g., sailing club).
  final EvDhtKey? groupDhtKey;

  /// When the event record was created.
  final EvTimestamp createdAt;

  /// When the event record was last updated.
  final EvTimestamp? updatedAt;

  /// Protocol version.
  final String evVersion;

  const EvEvent({
    this.dhtKey,
    required this.creatorPubkey,
    required this.name,
    this.description,
    required this.startAt,
    this.endAt,
    this.location,
    this.category,
    this.tags = const [],
    this.coverImageRef,
    this.ticketing,
    this.visibility = EvEventVisibility.public_,
    this.maxCapacity,
    this.rsvpCount = 0,
    this.groupDhtKey,
    required this.createdAt,
    this.updatedAt,
    this.evVersion = '0.1.0',
  });

  EvEvent copyWith({
    EvDhtKey? dhtKey,
    EvPubkey? creatorPubkey,
    String? name,
    String? description,
    EvTimestamp? startAt,
    EvTimestamp? endAt,
    EvEventLocation? location,
    String? category,
    List<String>? tags,
    EvMediaReference? coverImageRef,
    EvTicketing? ticketing,
    EvEventVisibility? visibility,
    int? maxCapacity,
    int? rsvpCount,
    EvDhtKey? groupDhtKey,
    EvTimestamp? createdAt,
    EvTimestamp? updatedAt,
  }) {
    return EvEvent(
      dhtKey: dhtKey ?? this.dhtKey,
      creatorPubkey: creatorPubkey ?? this.creatorPubkey,
      name: name ?? this.name,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      coverImageRef: coverImageRef ?? this.coverImageRef,
      ticketing: ticketing ?? this.ticketing,
      visibility: visibility ?? this.visibility,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      groupDhtKey: groupDhtKey ?? this.groupDhtKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.event.record',
        r'$ev_version': evVersion,
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'creatorPubkey': creatorPubkey.toString(),
        'name': name,
        if (description != null) 'description': description,
        'startAt': startAt.toIso8601(),
        if (endAt != null) 'endAt': endAt!.toIso8601(),
        if (location != null) 'location': location!.toJson(),
        if (category != null) 'category': category,
        if (tags.isNotEmpty) 'tags': tags,
        if (coverImageRef != null) 'coverImageRef': coverImageRef!.toJson(),
        if (ticketing != null) 'ticketing': ticketing!.toJson(),
        'visibility': visibility.name,
        if (maxCapacity != null) 'maxCapacity': maxCapacity,
        'rsvpCount': rsvpCount,
        if (groupDhtKey != null) 'groupDhtKey': groupDhtKey.toString(),
        'createdAt': createdAt.toIso8601(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601(),
      };

  factory EvEvent.fromJson(Map<String, dynamic> json) {
    return EvEvent(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      creatorPubkey: EvPubkey(json['creatorPubkey'] as String),
      name: json['name'] as String,
      description: json['description'] as String?,
      startAt: EvTimestamp.parse(json['startAt'] as String),
      endAt: json['endAt'] != null
          ? EvTimestamp.parse(json['endAt'] as String)
          : null,
      location: json['location'] != null
          ? EvEventLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      coverImageRef: json['coverImageRef'] != null
          ? EvMediaReference.fromJson(
              json['coverImageRef'] as Map<String, dynamic>)
          : null,
      ticketing: json['ticketing'] != null
          ? EvTicketing.fromJson(json['ticketing'] as Map<String, dynamic>)
          : null,
      visibility: EvEventVisibility.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => EvEventVisibility.public_,
      ),
      maxCapacity: json['maxCapacity'] as int?,
      rsvpCount: json['rsvpCount'] as int? ?? 0,
      groupDhtKey: json['groupDhtKey'] != null
          ? EvDhtKey(json['groupDhtKey'] as String)
          : null,
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? EvTimestamp.parse(json['updatedAt'] as String)
          : null,
      evVersion: json[r'$ev_version'] as String? ?? '0.1.0',
    );
  }
}

/// Event visibility levels.
enum EvEventVisibility {
  /// Anyone can discover and view this event.
  public_,

  /// Only people with the DHT key can view (unlisted).
  unlisted,

  /// Only invited members can view (encrypted attendee list).
  private_,

  /// Only group members can view.
  groupOnly,
}

/// Physical or virtual event location.
class EvEventLocation {
  /// Human-readable address or venue name.
  final String? name;

  /// Street address.
  final String? address;

  /// Latitude.
  final double? latitude;

  /// Longitude.
  final double? longitude;

  /// Geohash for DHT-based location search (6 characters).
  final String? geohash;

  /// Virtual event URL (Zoom, Meet, etc.).
  final String? virtualUrl;

  const EvEventLocation({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.geohash,
    this.virtualUrl,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (geohash != null) 'geohash': geohash,
        if (virtualUrl != null) 'virtualUrl': virtualUrl,
      };

  factory EvEventLocation.fromJson(Map<String, dynamic> json) {
    return EvEventLocation(
      name: json['name'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geohash: json['geohash'] as String?,
      virtualUrl: json['virtualUrl'] as String?,
    );
  }
}

/// Ticketing configuration for a paid event.
class EvTicketing {
  /// Pricing model.
  final EvTicketModel model;

  /// Available ticket tiers.
  final List<EvTicketTier> tiers;

  /// ISO 4217 currency code.
  final String currency;

  /// Accepted payment methods.
  final List<EvPaymentMethod> acceptedMethods;

  /// Refund policy.
  final EvRefundPolicy? refundPolicy;

  const EvTicketing({
    required this.model,
    required this.tiers,
    required this.currency,
    required this.acceptedMethods,
    this.refundPolicy,
  });

  Map<String, dynamic> toJson() => {
        'model': model.name,
        'tiers': tiers.map((t) => t.toJson()).toList(),
        'currency': currency,
        'acceptedMethods': acceptedMethods.map((m) => m.toJson()).toList(),
        if (refundPolicy != null) 'refundPolicy': refundPolicy!.toJson(),
      };

  factory EvTicketing.fromJson(Map<String, dynamic> json) {
    return EvTicketing(
      model: EvTicketModel.values.firstWhere(
        (m) => m.name == json['model'],
        orElse: () => EvTicketModel.free,
      ),
      tiers: (json['tiers'] as List<dynamic>)
          .map((t) => EvTicketTier.fromJson(t as Map<String, dynamic>))
          .toList(),
      currency: json['currency'] as String,
      acceptedMethods: (json['acceptedMethods'] as List<dynamic>)
          .map((m) => EvPaymentMethod.fromJson(m as Map<String, dynamic>))
          .toList(),
      refundPolicy: json['refundPolicy'] != null
          ? EvRefundPolicy.fromJson(
              json['refundPolicy'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Ticket pricing model.
enum EvTicketModel { free, fixed, tiered, sliding, donation, subscription }

/// A ticket tier within an event.
class EvTicketTier {
  final String name;
  final int priceMinor;
  final int? maxPriceMinor;
  final int? quantity;
  final String? description;
  final EvTimestamp? salesStart;
  final EvTimestamp? salesEnd;

  const EvTicketTier({
    required this.name,
    required this.priceMinor,
    this.maxPriceMinor,
    this.quantity,
    this.description,
    this.salesStart,
    this.salesEnd,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'priceMinor': priceMinor,
        if (maxPriceMinor != null) 'maxPriceMinor': maxPriceMinor,
        if (quantity != null) 'quantity': quantity,
        if (description != null) 'description': description,
        if (salesStart != null) 'salesStart': salesStart!.toIso8601(),
        if (salesEnd != null) 'salesEnd': salesEnd!.toIso8601(),
      };

  factory EvTicketTier.fromJson(Map<String, dynamic> json) {
    return EvTicketTier(
      name: json['name'] as String,
      priceMinor: json['priceMinor'] as int,
      maxPriceMinor: json['maxPriceMinor'] as int?,
      quantity: json['quantity'] as int?,
      description: json['description'] as String?,
      salesStart: json['salesStart'] != null
          ? EvTimestamp.parse(json['salesStart'] as String)
          : null,
      salesEnd: json['salesEnd'] != null
          ? EvTimestamp.parse(json['salesEnd'] as String)
          : null,
    );
  }
}

/// Refund policy configuration.
class EvRefundPolicy {
  final EvRefundType type;
  final int? cutoffHours;
  final String? description;

  const EvRefundPolicy({
    required this.type,
    this.cutoffHours,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (cutoffHours != null) 'cutoffHours': cutoffHours,
        if (description != null) 'description': description,
      };

  factory EvRefundPolicy.fromJson(Map<String, dynamic> json) {
    return EvRefundPolicy(
      type: EvRefundType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => EvRefundType.none,
      ),
      cutoffHours: json['cutoffHours'] as int?,
      description: json['description'] as String?,
    );
  }
}

enum EvRefundType { full, partial, none, conditional }

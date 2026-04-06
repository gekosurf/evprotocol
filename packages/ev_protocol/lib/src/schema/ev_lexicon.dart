/// Lexicon registry and schema definitions for the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant Dev as Developer
///     participant Reg as EvLexiconRegistry
///     participant Val as EvSchemaValidator
///     participant DHT as Veilid DHT
///
///     Note over Dev,DHT: REGISTER A LEXICON
///     Dev->>Reg: registerLexicon(schemaJson)
///     Reg->>Reg: Validate meta-schema structure
///     Reg-->>Dev: Registered ✓
///
///     Note over Dev,DHT: VALIDATE A RECORD
///     Dev->>Val: validate("ev.event.record", data)
///     Val->>Reg: getLexicon("ev.event.record")
///     Reg-->>Val: Schema definition
///     Val->>Val: Check required fields
///     Val->>Val: Check types and constraints
///     Val-->>Dev: Valid ✓ (or list of errors)
///
///     Note over Dev,DHT: UNKNOWN SCHEMA HANDLING
///     Dev->>Reg: getLexicon("ev.music.setlist")
///     Reg-->>Dev: null (unknown)
///     Note over Dev: Preserve raw JSON<br/>Don't discard unknown schemas
/// ```
class EvLexiconRegistry {
  final Map<String, Map<String, dynamic>> _schemas = {};

  /// Registers a Lexicon schema definition.
  ///
  /// The schema must have a valid `id` and `lexicon` version.
  /// Throws [ArgumentError] if the schema is malformed.
  void registerLexicon(Map<String, dynamic> schemaJson) {
    final id = schemaJson['id'] as String?;
    final lexiconVersion = schemaJson['lexicon'] as int?;

    if (id == null || id.isEmpty) {
      throw ArgumentError('Lexicon must have a non-empty "id" field');
    }
    if (lexiconVersion == null || lexiconVersion < 1) {
      throw ArgumentError('Lexicon must have a "lexicon" version >= 1');
    }

    _schemas[id] = Map<String, dynamic>.from(schemaJson);
  }

  /// Registers multiple Lexicon schemas at once.
  void registerAll(List<Map<String, dynamic>> schemas) {
    for (final schema in schemas) {
      registerLexicon(schema);
    }
  }

  /// Gets a registered Lexicon by its ID.
  ///
  /// Returns null if the schema is not registered.
  Map<String, dynamic>? getLexicon(String id) => _schemas[id];

  /// Checks if a Lexicon is registered.
  bool hasLexicon(String id) => _schemas.containsKey(id);

  /// Lists all registered Lexicon IDs.
  List<String> get registeredIds => _schemas.keys.toList();

  /// Lists all registered Lexicons in a specific namespace.
  ///
  /// Example: `listByNamespace('ev.sailing')` returns all sailing schemas.
  List<String> listByNamespace(String namespace) {
    return _schemas.keys
        .where((id) => id.startsWith('$namespace.'))
        .toList();
  }

  /// Unregisters a Lexicon.
  void unregisterLexicon(String id) {
    _schemas.remove(id);
  }

  /// Returns the total number of registered Lexicons.
  int get count => _schemas.length;
}

/// Core EV Protocol Lexicon IDs (v0.1).
///
/// These are the schema IDs defined in the protocol spec.
/// Use these constants instead of string literals.
abstract class EvLexicons {
  // Identity
  static const identityProfile = 'ev.identity.profile';
  static const identityBridge = 'ev.identity.bridge';

  // Events
  static const eventRecord = 'ev.event.record';
  static const eventRsvp = 'ev.event.rsvp';

  // Groups & Vessels
  static const groupRoster = 'ev.group.roster';
  static const groupVessel = 'ev.group.vessel';

  // Media
  static const mediaReference = 'ev.media.reference';

  // Payments
  static const paymentIntent = 'ev.payment.intent';
  static const paymentReceipt = 'ev.payment.receipt';
  static const ticketToken = 'ev.ticket.token';

  // Chat
  static const chatChannel = 'ev.chat.channel';
  static const chatMessage = 'ev.chat.message';
  static const chatAnnouncement = 'ev.chat.announcement';

  // Moderation
  static const moderationReport = 'ev.moderation.report';
  static const moderationAction = 'ev.moderation.action';

  // Search
  static const searchIndex = 'ev.search.index';

  // Sailing extension
  static const sailingRace = 'ev.sailing.race';
  static const sailingResult = 'ev.sailing.result';
  static const sailingTrack = 'ev.sailing.track';
  static const sailingCourse = 'ev.sailing.course';

  /// All core Lexicon IDs.
  static const List<String> allCore = [
    identityProfile,
    identityBridge,
    eventRecord,
    eventRsvp,
    groupRoster,
    groupVessel,
    mediaReference,
    paymentIntent,
    paymentReceipt,
    ticketToken,
    chatChannel,
    chatMessage,
    chatAnnouncement,
    moderationReport,
    moderationAction,
    searchIndex,
  ];

  /// All sailing extension Lexicon IDs.
  static const List<String> allSailing = [
    sailingRace,
    sailingResult,
    sailingTrack,
    sailingCourse,
  ];

  /// All Lexicon IDs in v0.1.
  static const List<String> allV01 = [...allCore, ...allSailing];
}

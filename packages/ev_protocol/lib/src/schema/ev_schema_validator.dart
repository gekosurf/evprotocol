/// Abstract interface for schema validation in the EV Protocol.
///
/// Implementations validate data against registered Lexicon schemas
/// before records are written to the DHT or local store.
abstract class EvSchemaValidator {
  /// Validates a data map against a registered Lexicon schema.
  ///
  /// Returns a list of validation errors. Empty list = valid.
  List<EvValidationError> validate(
    String schemaId,
    Map<String, dynamic> data,
  );

  /// Validates and returns true if the data is valid.
  bool isValid(String schemaId, Map<String, dynamic> data) {
    return validate(schemaId, data).isEmpty;
  }

  /// Extracts the schema ID from a record's `$type` field.
  static String? extractSchemaId(Map<String, dynamic> data) {
    return data[r'$type'] as String?;
  }

  /// Extracts the protocol version from a record's `$ev_version` field.
  static String? extractVersion(Map<String, dynamic> data) {
    return data[r'$ev_version'] as String?;
  }
}

/// A validation error returned by the schema validator.
class EvValidationError {
  /// The field path that failed validation (e.g., "ticketing.tiers[0].priceMinor").
  final String field;

  /// Human-readable error message.
  final String message;

  /// The type of validation error.
  final EvValidationErrorType type;

  const EvValidationError({
    required this.field,
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'EvValidationError($field): $message';
}

/// Types of validation errors.
enum EvValidationErrorType {
  /// A required field is missing.
  requiredFieldMissing,

  /// A field has the wrong type.
  typeMismatch,

  /// A string exceeds maxLength.
  maxLengthExceeded,

  /// A number is below minimum.
  belowMinimum,

  /// A number exceeds maximum.
  aboveMaximum,

  /// A string doesn't match the expected format (e.g., datetime).
  formatInvalid,

  /// A referenced schema is not registered.
  unknownReference,

  /// The schema ID is not registered in the Lexicon registry.
  unknownSchema,
}

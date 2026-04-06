/// A Result type for all protocol service operations.
///
/// All service methods return [EvResult] instead of throwing exceptions.
/// This enforces explicit error handling at every call site.
///
/// ```dart
/// final result = await eventService.createEvent(event);
/// switch (result) {
///   case EvSuccess(:final value): print('Created: ${value.name}');
///   case EvFailure(:final error): print('Failed: ${error.message}');
/// }
/// ```
sealed class EvResult<T> {
  const EvResult();

  /// Returns the value if successful, throws if failure.
  T get valueOrThrow;

  /// Returns the value if successful, null if failure.
  T? get valueOrNull;

  /// Whether this result is a success.
  bool get isSuccess;

  /// Whether this result is a failure.
  bool get isFailure;

  /// Maps the success value to a new type.
  EvResult<U> map<U>(U Function(T value) transform);

  /// Chains another operation on success.
  EvResult<U> flatMap<U>(EvResult<U> Function(T value) transform);
}

/// A successful result containing a value.
class EvSuccess<T> extends EvResult<T> {
  final T value;

  const EvSuccess(this.value);

  @override
  T get valueOrThrow => value;

  @override
  T? get valueOrNull => value;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  EvResult<U> map<U>(U Function(T value) transform) {
    return EvSuccess(transform(value));
  }

  @override
  EvResult<U> flatMap<U>(EvResult<U> Function(T value) transform) {
    return transform(value);
  }
}

/// A failed result containing an error.
class EvFailure<T> extends EvResult<T> {
  final EvError error;

  const EvFailure(this.error);

  @override
  T get valueOrThrow => throw EvProtocolException(error);

  @override
  T? get valueOrNull => null;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  EvResult<U> map<U>(U Function(T value) transform) {
    return EvFailure(error);
  }

  @override
  EvResult<U> flatMap<U>(EvResult<U> Function(T value) transform) {
    return EvFailure(error);
  }
}

/// Structured error from protocol operations.
class EvError {
  /// Error code for programmatic handling.
  final EvErrorCode code;

  /// Human-readable error message.
  final String message;

  /// Optional underlying error details.
  final Object? cause;

  const EvError({
    required this.code,
    required this.message,
    this.cause,
  });

  @override
  String toString() => 'EvError($code): $message';
}

/// Error codes for protocol operations.
enum EvErrorCode {
  /// The operation failed due to a network issue.
  networkError,

  /// The record was not found in DHT or local store.
  notFound,

  /// The record failed schema validation.
  validationError,

  /// The caller is not authorised for this operation.
  unauthorised,

  /// The operation conflicts with existing data.
  conflict,

  /// The record exceeds the maximum size.
  recordTooLarge,

  /// The operation timed out.
  timeout,

  /// The DHT key could not be resolved.
  dhtKeyResolutionFailed,

  /// The signature verification failed.
  signatureInvalid,

  /// The schema/lexicon is not registered.
  unknownSchema,

  /// The device is offline and the operation requires network.
  offline,

  /// A sync conflict occurred.
  syncConflict,

  /// An unknown or unclassified error.
  unknown,
}

/// Exception wrapping an [EvError] for use with [EvResult.valueOrThrow].
class EvProtocolException implements Exception {
  final EvError error;

  const EvProtocolException(this.error);

  @override
  String toString() => 'EvProtocolException(${error.code}): ${error.message}';
}

import 'package:ev_protocol/ev_protocol.dart';
import 'package:sailor/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Create a new identity during onboarding.
class CreateIdentityUseCase {
  final AuthRepository _repository;

  const CreateIdentityUseCase(this._repository);

  Future<EvIdentity> call({
    required String displayName,
    String? bio,
  }) {
    if (displayName.trim().isEmpty) {
      throw const AuthException('Display name cannot be empty');
    }
    if (displayName.trim().length > 64) {
      throw const AuthException('Display name must be 64 characters or less');
    }
    return _repository.createIdentity(
      displayName: displayName.trim(),
      bio: bio?.trim(),
    );
  }
}

/// Use case: Get the current authenticated identity.
class GetCurrentIdentityUseCase {
  final AuthRepository _repository;

  const GetCurrentIdentityUseCase(this._repository);

  Future<EvIdentity?> call() {
    return _repository.getCurrentIdentity();
  }
}

/// Use case: Get the backup key after identity creation.
class GetBackupKeyUseCase {
  final AuthRepository _repository;

  const GetBackupKeyUseCase(this._repository);

  Future<String> call() {
    return _repository.getBackupKey();
  }
}

/// Use case: Restore identity from a backup key.
class RestoreIdentityUseCase {
  final AuthRepository _repository;

  const RestoreIdentityUseCase(this._repository);

  Future<EvIdentity> call(String backupKey) {
    if (backupKey.trim().isEmpty) {
      throw const AuthException('Backup key cannot be empty');
    }
    return _repository.restoreFromBackup(backupKey.trim());
  }
}

/// Domain exception for auth operations.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

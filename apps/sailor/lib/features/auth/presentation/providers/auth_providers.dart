import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/db/database_provider.dart';
import 'package:sailor/features/auth/data/repositories/drift_auth_repository.dart';
import 'package:sailor/features/auth/domain/repositories/auth_repository.dart';
import 'package:sailor/features/auth/domain/usecases/auth_usecases.dart';

// === REPOSITORY (now backed by SQLite) ===
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftAuthRepository(db);
});

// === USE CASES ===
final createIdentityUseCaseProvider = Provider<CreateIdentityUseCase>((ref) {
  return CreateIdentityUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentIdentityUseCaseProvider =
    Provider<GetCurrentIdentityUseCase>((ref) {
  return GetCurrentIdentityUseCase(ref.watch(authRepositoryProvider));
});

final getBackupKeyUseCaseProvider = Provider<GetBackupKeyUseCase>((ref) {
  return GetBackupKeyUseCase(ref.watch(authRepositoryProvider));
});

final restoreIdentityUseCaseProvider =
    Provider<RestoreIdentityUseCase>((ref) {
  return RestoreIdentityUseCase(ref.watch(authRepositoryProvider));
});

// === AUTH STATE ===
/// Watches the current identity. Null means not authenticated.
final authStateProvider = FutureProvider<EvIdentity?>((ref) async {
  final useCase = ref.watch(getCurrentIdentityUseCaseProvider);
  return useCase();
});

/// Notifier for creating an identity during onboarding.
final createIdentityProvider =
    AsyncNotifierProvider<CreateIdentityNotifier, EvIdentity?>(
  CreateIdentityNotifier.new,
);

class CreateIdentityNotifier extends AsyncNotifier<EvIdentity?> {
  @override
  Future<EvIdentity?> build() async => null;

  Future<EvIdentity> create({
    required String displayName,
    String? bio,
  }) async {
    state = const AsyncLoading();
    final identity = await AsyncValue.guard(() async {
      final useCase = ref.read(createIdentityUseCaseProvider);
      return useCase(displayName: displayName, bio: bio);
    });
    state = identity;

    // Invalidate auth state so router redirects
    ref.invalidate(authStateProvider);

    return identity.requireValue;
  }
}

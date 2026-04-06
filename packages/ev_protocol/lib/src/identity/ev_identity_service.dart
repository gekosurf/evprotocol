import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_result.dart';
import 'ev_identity.dart';
import 'ev_identity_bridge.dart';

/// Abstract interface for identity management in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant App as Flutter App
///     participant Svc as EvIdentityService
///     participant Keychain as Secure Enclave
///     participant DHT as Veilid DHT
///
///     Note over App,DHT: CREATE IDENTITY
///     App->>Svc: createIdentity(displayName)
///     Svc->>Keychain: Generate Ed25519 keypair
///     Keychain-->>Svc: {pubkey, privkey}
///     Svc->>DHT: Publish ev.identity.profile
///     DHT-->>Svc: Published ✓
///     Svc-->>App: EvSuccess(EvIdentity)
///
///     Note over App,DHT: RESOLVE IDENTITY
///     App->>Svc: resolveIdentity(pubkey)
///     Svc->>DHT: Read ev.identity.profile
///     DHT-->>Svc: Profile JSON
///     Svc-->>App: EvSuccess(EvIdentity)
///
///     Note over App,DHT: LINK AT PROTOCOL (optional)
///     App->>Svc: linkAtProtocol(atDid, atSignature)
///     Svc->>DHT: Publish ev.identity.bridge
///     Svc-->>App: EvSuccess(EvIdentityBridge)
/// ```
abstract class EvIdentityService {
  /// Creates a new identity with a generated keypair.
  ///
  /// The keypair is stored in the device's secure storage
  /// and the profile is published to the DHT.
  Future<EvResult<EvIdentity>> createIdentity({
    required String displayName,
    String? bio,
  });

  /// Returns the current user's identity, if one exists.
  Future<EvResult<EvIdentity>> getCurrentIdentity();

  /// Returns the current user's public key, if one exists.
  Future<EvResult<EvPubkey>> getCurrentPubkey();

  /// Updates the current user's profile.
  Future<EvResult<EvIdentity>> updateProfile({
    String? displayName,
    String? bio,
    EvDhtKey? avatarRefKey,
  });

  /// Resolves another user's identity by their public key.
  Future<EvResult<EvIdentity>> resolveIdentity(EvPubkey pubkey);

  /// Resolves multiple identities in batch.
  Future<EvResult<List<EvIdentity>>> resolveIdentities(List<EvPubkey> pubkeys);

  /// Links the current identity to an AT Protocol DID.
  ///
  /// Requires:
  /// - The AT Protocol DID
  /// - The AT Protocol key's signature over the Veilid pubkey
  Future<EvResult<EvIdentityBridge>> linkAtProtocol({
    required String atDid,
    required String atHandle,
    required String atSignature,
  });

  /// Resolves an AT Protocol bridge for a given Veilid pubkey.
  Future<EvResult<EvIdentityBridge?>> resolveAtBridge(EvPubkey pubkey);

  /// Exports the current identity as an encrypted key bundle.
  ///
  /// Used for device migration (QR code or encrypted file).
  Future<EvResult<List<int>>> exportIdentity({required String passphrase});

  /// Imports an identity from an encrypted key bundle.
  Future<EvResult<EvIdentity>> importIdentity({
    required List<int> encryptedBundle,
    required String passphrase,
  });

  /// Deletes the current identity and all associated data.
  ///
  /// This overwrites DHT records with empty data and deletes local storage.
  Future<EvResult<void>> deleteIdentity();
}

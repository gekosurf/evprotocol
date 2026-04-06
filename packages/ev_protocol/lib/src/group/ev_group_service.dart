import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_result.dart';
import 'ev_group.dart';
import 'ev_vessel.dart';

/// Abstract interface for group and vessel management.
///
/// ```mermaid
/// sequenceDiagram
///     participant Admin as Club Admin
///     participant Svc as EvGroupService
///     participant DHT as Veilid DHT
///     participant Member as New Member
///
///     Note over Admin,Member: CREATE GROUP
///     Admin->>Svc: createGroup(name, ...)
///     Svc->>DHT: Write ev.group.roster
///     Svc-->>Admin: EvSuccess(EvGroup)
///
///     Note over Admin,Member: REGISTER VESSEL
///     Admin->>Svc: registerVessel(vessel)
///     Svc->>DHT: Write ev.group.vessel
///     Svc->>DHT: Add vessel key to group roster
///     Svc-->>Admin: EvSuccess(EvVessel)
///
///     Note over Admin,Member: ADD MEMBER
///     Admin->>Svc: addMember(groupKey, pubkey, role)
///     Svc->>DHT: Update ev.group.roster members
///     Svc-->>Admin: EvSuccess(EvGroup)
///
///     Note over Admin,Member: MEMBER VIEWS GROUP
///     Member->>Svc: getGroup(groupKey)
///     Svc->>DHT: Read ev.group.roster
///     Svc-->>Member: EvSuccess(EvGroup)
/// ```
abstract class EvGroupService {
  /// Creates a new group.
  Future<EvResult<EvGroup>> createGroup({
    required String name,
    String? description,
    EvGroupVisibility visibility = EvGroupVisibility.public_,
  });

  /// Gets a group by DHT key.
  Future<EvResult<EvGroup>> getGroup(EvDhtKey dhtKey);

  /// Updates group metadata (admin only).
  Future<EvResult<EvGroup>> updateGroup(EvGroup group);

  /// Deletes a group (admin only).
  Future<EvResult<void>> deleteGroup(EvDhtKey dhtKey);

  /// Lists groups the current user belongs to.
  Future<EvResult<List<EvGroup>>> listMyGroups();

  /// Adds a member to a group (admin/organiser only).
  Future<EvResult<EvGroup>> addMember({
    required EvDhtKey groupDhtKey,
    required EvPubkey memberPubkey,
    EvGroupRole role = EvGroupRole.member,
    String? displayName,
  });

  /// Removes a member from a group.
  Future<EvResult<EvGroup>> removeMember({
    required EvDhtKey groupDhtKey,
    required EvPubkey memberPubkey,
  });

  /// Updates a member's role.
  Future<EvResult<EvGroup>> updateMemberRole({
    required EvDhtKey groupDhtKey,
    required EvPubkey memberPubkey,
    required EvGroupRole newRole,
  });

  /// Registers a vessel to a group.
  Future<EvResult<EvVessel>> registerVessel(EvVessel vessel);

  /// Gets a vessel by DHT key.
  Future<EvResult<EvVessel>> getVessel(EvDhtKey dhtKey);

  /// Updates vessel details (owner only).
  Future<EvResult<EvVessel>> updateVessel(EvVessel vessel);

  /// Lists all vessels in a group.
  Future<EvResult<List<EvVessel>>> listGroupVessels(EvDhtKey groupDhtKey);

  /// Lists vessels owned by the current user.
  Future<EvResult<List<EvVessel>>> listMyVessels();
}

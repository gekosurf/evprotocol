import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('admin-key');

  group('EvGroup', () {
    test('JSON roundtrip', () {
      final group = EvGroup(
        dhtKey: const EvDhtKey('group-1'),
        name: 'Royal Perth Yacht Club',
        description: 'Founded 1865',
        adminPubkey: _pubkey,
        members: [
          EvGroupMember(
            pubkey: _pubkey,
            displayName: 'Admin',
            role: EvGroupRole.admin,
            joinedAt: _now,
          ),
          EvGroupMember(
            pubkey: EvPubkey.fromRawKey('member-key'),
            displayName: 'Bob',
            role: EvGroupRole.member,
            joinedAt: _now,
          ),
        ],
        vesselDhtKeys: [const EvDhtKey('vessel-1'), const EvDhtKey('vessel-2')],
        visibility: EvGroupVisibility.public_,
        createdAt: _now,
      );

      final json = group.toJson();
      expect(json[r'$type'], 'ev.group.roster');
      expect(json['members'], hasLength(2));
      expect(json['vesselDhtKeys'], hasLength(2));

      final restored = EvGroup.fromJson(json);
      expect(restored.name, 'Royal Perth Yacht Club');
      expect(restored.members.length, 2);
      expect(restored.members[0].role, EvGroupRole.admin);
      expect(restored.members[1].displayName, 'Bob');
      expect(restored.vesselDhtKeys.length, 2);
    });

    test('copyWith', () {
      final group = EvGroup(
        name: 'Club A',
        adminPubkey: _pubkey,
        createdAt: _now,
      );
      final updated = group.copyWith(name: 'Club B');
      expect(updated.name, 'Club B');
      expect(updated.adminPubkey, _pubkey);
    });

    test('all roles serialize', () {
      for (final role in EvGroupRole.values) {
        final member = EvGroupMember(
          pubkey: _pubkey,
          role: role,
          joinedAt: _now,
        );
        final json = member.toJson();
        final restored = EvGroupMember.fromJson(json);
        expect(restored.role, role);
      }
    });
  });

  group('EvVessel', () {
    test('JSON roundtrip', () {
      final vessel = EvVessel(
        dhtKey: const EvDhtKey('vessel-1'),
        name: 'Southern Cross',
        ownerPubkey: _pubkey,
        sailNumber: 'AUS 123',
        vesselClass: 'S97',
        handicap: 1.05,
        lengthMetres: 9.7,
        homePort: 'Fremantle',
        groupDhtKey: const EvDhtKey('group-1'),
        crew: [
          const EvCrewMember(displayName: 'Alice', role: EvCrewRole.skipper),
          EvCrewMember(pubkey: _pubkey, displayName: 'Bob', role: EvCrewRole.tactician),
        ],
      );

      final json = vessel.toJson();
      expect(json[r'$type'], 'ev.group.vessel');
      expect(json['sailNumber'], 'AUS 123');
      expect(json['class'], 'S97');
      expect(json['handicap'], 1.05);
      expect(json['crew'], hasLength(2));

      final restored = EvVessel.fromJson(json);
      expect(restored.name, 'Southern Cross');
      expect(restored.vesselClass, 'S97');
      expect(restored.handicap, 1.05);
      expect(restored.lengthMetres, 9.7);
      expect(restored.crew.length, 2);
      expect(restored.crew[0].role, EvCrewRole.skipper);
      expect(restored.crew[1].role, EvCrewRole.tactician);
    });

    test('copyWith', () {
      final vessel = EvVessel(
        name: 'Boat A',
        ownerPubkey: _pubkey,
        handicap: 1.0,
      );
      final updated = vessel.copyWith(handicap: 1.1, sailNumber: 'X99');
      expect(updated.handicap, 1.1);
      expect(updated.sailNumber, 'X99');
      expect(updated.name, 'Boat A');
    });

    test('all crew roles', () {
      for (final role in EvCrewRole.values) {
        final crew = EvCrewMember(role: role);
        final json = crew.toJson();
        final restored = EvCrewMember.fromJson(json);
        expect(restored.role, role);
      }
    });
  });
}

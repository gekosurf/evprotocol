import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:flutter/foundation.dart';

/// Client for querying AT Protocol PDS repos directly.
///
/// Phase 3: Direct PDS queries for cross-user event/RSVP discovery.
/// Future: Replace with Smoke Signal AppView API when available.
class SmokeSignalApi {
  final AtAuthService _auth;

  SmokeSignalApi(this._auth);

  /// Fetch an event from a specific user's PDS via AT URI.
  ///
  /// URI format: at://did:plc:xxx/events.smokesignal.calendar.event/rkey
  Future<SmokeSignalEvent?> getEventByUri(String atUri) async {
    final client = _auth.client;
    if (client == null) return null;

    try {
      final parts = _parseAtUri(atUri);
      if (parts == null) return null;

      final result = await client.atproto.repo.getRecord(
        repo: parts.did,
        collection: parts.collection,
        rkey: parts.rkey,
      );
      return SmokeSignalEvent.fromRecord(result.data.value);
    } catch (e) {
      debugPrint('[SmokeSignalApi] Failed to fetch event: $e');
      return null;
    }
  }

  /// List all events in a user's PDS repo.
  Future<List<({SmokeSignalEvent event, String atUri})>> listUserEvents(
      String did) async {
    final client = _auth.client;
    if (client == null) return [];

    try {
      final result = await client.atproto.repo.listRecords(
        repo: did,
        collection: LexiconNsids.event,
      );

      return result.data.records.map((record) {
        return (
          event: SmokeSignalEvent.fromRecord(record.value),
          atUri: record.uri.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SmokeSignalApi] Failed to list events for $did: $e');
      return [];
    }
  }

  /// List all RSVPs in a user's PDS repo.
  Future<List<({SmokeSignalRsvp rsvp, String atUri})>> listUserRsvps(
      String did) async {
    final client = _auth.client;
    if (client == null) return [];

    try {
      final result = await client.atproto.repo.listRecords(
        repo: did,
        collection: LexiconNsids.rsvp,
      );

      return result.data.records.map((record) {
        return (
          rsvp: SmokeSignalRsvp.fromRecord(record.value),
          atUri: record.uri.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SmokeSignalApi] Failed to list RSVPs for $did: $e');
      return [];
    }
  }

  /// Get RSVPs for a specific event by scanning known participants.
  ///
  /// Phase 3: Scans a provided list of participant DIDs.
  /// Future: Use AppView for aggregated RSVP query.
  Future<List<({SmokeSignalRsvp rsvp, String attendeeDid})>>
      getRsvpsForEvent(String eventAtUri, List<String> participantDids) async {
    final results = <({SmokeSignalRsvp rsvp, String attendeeDid})>[];

    for (final did in participantDids) {
      final rsvps = await listUserRsvps(did);
      for (final entry in rsvps) {
        if (entry.rsvp.eventUri == eventAtUri) {
          results.add((rsvp: entry.rsvp, attendeeDid: did));
        }
      }
    }

    return results;
  }

  /// Get the current user's own events from their PDS.
  Future<List<({SmokeSignalEvent event, String atUri})>>
      getMyEvents() async {
    final did = _auth.did;
    if (did == null) return [];
    return listUserEvents(did);
  }

  /// Get the current user's own RSVPs from their PDS.
  Future<List<({SmokeSignalRsvp rsvp, String atUri})>>
      getMyRsvps() async {
    final did = _auth.did;
    if (did == null) return [];
    return listUserRsvps(did);
  }
}

/// Parsed AT URI components.
class _AtUriParts {
  final String did;
  final String collection;
  final String rkey;
  const _AtUriParts(this.did, this.collection, this.rkey);
}

_AtUriParts? _parseAtUri(String atUri) {
  if (!atUri.startsWith('at://')) return null;
  final parts = atUri.replaceFirst('at://', '').split('/');
  if (parts.length < 3) return null;
  return _AtUriParts(parts[0], parts[1], parts[2]);
}

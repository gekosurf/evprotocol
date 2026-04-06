import '../core/ev_dht_key.dart';
import '../core/ev_result.dart';
import 'ev_event.dart';
import 'ev_rsvp.dart';

/// Abstract interface for event management in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant Org as Organiser App
///     participant Svc as EvEventService
///     participant DHT as Veilid DHT
///     participant Att as Attendee App
///
///     Note over Org,Att: CREATE EVENT
///     Org->>Svc: createEvent(event)
///     Svc->>Svc: Validate against ev.event.record schema
///     Svc->>DHT: Write multi-writer DHT record
///     Svc->>DHT: Write geohash index key
///     Svc->>DHT: Write time index key
///     DHT-->>Svc: Published ✓
///     Svc-->>Org: EvSuccess(EvEvent with dhtKey)
///
///     Note over Org,Att: RSVP TO EVENT
///     Att->>Svc: rsvp(eventDhtKey, ...)
///     Svc->>DHT: Read event (verify capacity)
///     Svc->>DHT: Write ev.event.rsvp record
///     Svc-->>Att: EvSuccess(EvRsvp)
///
///     Note over Org,Att: LIST ATTENDEES
///     Org->>Svc: listRsvps(eventDhtKey)
///     Svc->>DHT: Scan RSVP records for event
///     DHT-->>Svc: [EvRsvp, EvRsvp, ...]
///     Svc-->>Org: EvSuccess(List<EvRsvp>)
/// ```
abstract class EvEventService {
  /// Creates a new event and publishes it to the DHT.
  Future<EvResult<EvEvent>> createEvent(EvEvent event);

  /// Reads an event by its DHT key.
  Future<EvResult<EvEvent>> getEvent(EvDhtKey dhtKey);

  /// Updates an existing event (only the creator can update).
  Future<EvResult<EvEvent>> updateEvent(EvEvent event);

  /// Deletes an event (overwrites DHT record with empty data).
  Future<EvResult<void>> deleteEvent(EvDhtKey dhtKey);

  /// Lists events created by the current user.
  Future<EvResult<List<EvEvent>>> listMyEvents();

  /// Lists events within a group.
  Future<EvResult<List<EvEvent>>> listGroupEvents(EvDhtKey groupDhtKey);

  /// Creates an RSVP for the current user to an event.
  Future<EvResult<EvRsvp>> rsvp({
    required EvDhtKey eventDhtKey,
    EvRsvpStatus status = EvRsvpStatus.pending,
    String? tierName,
    String? message,
    int guestCount = 0,
    bool isPublic = true,
  });

  /// Gets the current user's RSVP for an event, if one exists.
  Future<EvResult<EvRsvp?>> getMyRsvp(EvDhtKey eventDhtKey);

  /// Updates the current user's RSVP.
  Future<EvResult<EvRsvp>> updateRsvp(EvRsvp rsvp);

  /// Cancels the current user's RSVP.
  Future<EvResult<void>> cancelRsvp(EvDhtKey eventDhtKey);

  /// Lists all RSVPs for an event (organiser only sees full list).
  Future<EvResult<List<EvRsvp>>> listRsvps(EvDhtKey eventDhtKey);

  /// Gets the RSVP count for an event (public, approximate).
  Future<EvResult<int>> getRsvpCount(EvDhtKey eventDhtKey);

  /// Lists upcoming events the current user has RSVP'd to.
  Future<EvResult<List<EvEvent>>> listMyUpcomingEvents();

  /// Watches an event for real-time updates.
  ///
  /// Returns a stream of updated event records.
  Stream<EvEvent> watchEvent(EvDhtKey dhtKey);
}

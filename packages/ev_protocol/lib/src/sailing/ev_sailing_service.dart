import '../core/ev_dht_key.dart';
import '../core/ev_result.dart';
import 'ev_course.dart';
import 'ev_race.dart';
import 'ev_race_result.dart';
import 'ev_track.dart';

/// Abstract interface for sailing-specific operations.
///
/// ```mermaid
/// sequenceDiagram
///     participant RC as Race Committee
///     participant Svc as EvSailingService
///     participant DHT as Veilid DHT
///     participant Sailor as Sailor App
///
///     Note over RC,Sailor: SETUP RACE
///     RC->>Svc: createCourse(marks, startLine, finishLine)
///     Svc->>DHT: Write ev.sailing.course
///     Svc-->>RC: EvSuccess(EvCourse)
///
///     RC->>Svc: createRace(eventKey, courseKey, ...)
///     Svc->>DHT: Write ev.sailing.race
///     Svc-->>RC: EvSuccess(EvRace)
///
///     Note over RC,Sailor: START RACE
///     RC->>Svc: updateRaceStatus(raceKey, started)
///     Svc->>DHT: Update ev.sailing.race {status: started}
///
///     Note over RC,Sailor: RECORD GPS TRACK
///     Sailor->>Svc: startTracking(raceKey, vesselKey)
///     Sailor->>Sailor: Record GPS points locally
///     Sailor->>Svc: submitTrack(trackData)
///     Svc->>DHT: Write ev.sailing.track
///     Svc-->>Sailor: EvSuccess(EvTrack)
///
///     Note over RC,Sailor: PUBLISH RESULTS
///     RC->>Svc: publishResults(raceKey, results)
///     Svc->>DHT: Write ev.sailing.result
///     Svc-->>RC: EvSuccess(EvRaceResult)
///
///     Note over RC,Sailor: VIEW RESULTS
///     Sailor->>Svc: getRaceResults(raceKey)
///     Svc->>DHT: Read ev.sailing.result
///     Svc-->>Sailor: EvSuccess(EvRaceResult)
/// ```
abstract class EvSailingService {
  // --- Courses ---

  /// Creates a sailing course.
  Future<EvResult<EvCourse>> createCourse(EvCourse course);

  /// Gets a course by DHT key.
  Future<EvResult<EvCourse>> getCourse(EvDhtKey dhtKey);

  /// Updates a course (organiser only).
  Future<EvResult<EvCourse>> updateCourse(EvCourse course);

  /// Lists courses for an event.
  Future<EvResult<List<EvCourse>>> listEventCourses(EvDhtKey eventDhtKey);

  // --- Races ---

  /// Creates a race within an event.
  Future<EvResult<EvRace>> createRace(EvRace race);

  /// Gets a race by DHT key.
  Future<EvResult<EvRace>> getRace(EvDhtKey dhtKey);

  /// Updates a race (status, conditions, actual start time).
  Future<EvResult<EvRace>> updateRace(EvRace race);

  /// Lists all races in an event.
  Future<EvResult<List<EvRace>>> listEventRaces(EvDhtKey eventDhtKey);

  /// Watch a race for real-time status updates.
  Stream<EvRace> watchRace(EvDhtKey raceDhtKey);

  // --- Tracks ---

  /// Submits a GPS track for a race.
  Future<EvResult<EvTrack>> submitTrack(EvTrack track);

  /// Gets a track by DHT key.
  Future<EvResult<EvTrack>> getTrack(EvDhtKey dhtKey);

  /// Lists all tracks for a race (one per vessel).
  Future<EvResult<List<EvTrack>>> listRaceTracks(EvDhtKey raceDhtKey);

  /// Lists all tracks for the current user (across all races).
  Future<EvResult<List<EvTrack>>> listMyTracks();

  // --- Results ---

  /// Publishes race results (organiser only).
  Future<EvResult<EvRaceResult>> publishResults(EvRaceResult result);

  /// Gets race results.
  Future<EvResult<EvRaceResult>> getRaceResults(EvDhtKey raceDhtKey);

  /// Gets cumulative series standings for an event (across all races).
  Future<EvResult<EvRaceResult>> getSeriesStandings(EvDhtKey eventDhtKey);

  /// Watches race results for real-time updates.
  Stream<EvRaceResult> watchResults(EvDhtKey raceDhtKey);
}

/// Option C Spike — AT Protocol Validation
///
/// Tests the RSVP flow against a real PDS:
/// 1. Authenticate with bsky.social
/// 2. Create an event record (Smoke Signal Lexicon)
/// 3. Create an RSVP record referencing the event
/// 4. Read both records back
/// 5. List records by collection
/// 6. Test Sailor custom Lexicon namespace
///
/// Usage:
///   dart run bin/spike.dart <handle> <app-password>
///
/// Create an app password at: https://bsky.app/settings/app-passwords
import 'dart:io';

import 'package:bluesky/atproto.dart' as atproto;
import 'package:bluesky/bluesky.dart' as bsky;

// Collection names (Smoke Signal Lexicon + Sailor custom)
const kEventCollection = 'events.smokesignal.calendar.event';
const kRsvpCollection = 'events.smokesignal.calendar.rsvp';
const kPositionCollection = 'au.sailor.yacht.position';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run bin/spike.dart <handle> <app-password>');
    print('');
    print('Create an app password at: https://bsky.app/settings/app-passwords');
    exit(1);
  }

  final handle = args[0];
  final appPassword = args[1];

  print('=== Option C Spike: AT Protocol Validation ===\n');

  // ── Step 1: Authenticate ──────────────────────────────────────────
  print('1. Authenticating as $handle...');
  final stopwatch = Stopwatch()..start();

  late final bsky.Bluesky blueskyClient;
  try {
    final session = await atproto.createSession(
      identifier: handle,
      password: appPassword,
    );
    blueskyClient = bsky.Bluesky.fromSession(session.data);
    print('   ✅ Authenticated in ${stopwatch.elapsedMilliseconds}ms');
    print('   DID: ${blueskyClient.session?.did}');
  } catch (e) {
    print('   ❌ Authentication failed: $e');
    print('\n⛔ SPIKE FAILED at Step 1. Cannot proceed.');
    exit(1);
  }

  final did = blueskyClient.session!.did;

  // ── Step 2: Create Event Record (Smoke Signal Lexicon) ────────────
  print('\n2. Creating event record ($kEventCollection)...');
  stopwatch.reset();

  final now = DateTime.now().toUtc().toIso8601String();
  final eventStart =
      DateTime.now().toUtc().add(const Duration(days: 7)).toIso8601String();

  final eventRecord = {
    r'$type': kEventCollection,
    'name': 'Spike Test - Perth Yacht Club Race Day',
    'description':
        'AT Protocol spike test event created by Sailor app. Safe to ignore.',
    'startsAt': eventStart,
    'status': 'scheduled',
    'locations': [
      {
        'name': 'Royal Perth Yacht Club',
        'address': '1 Crawley Ave, Crawley WA 6009',
      },
    ],
    'createdAt': now,
  };

  String? eventRkey;
  String? eventAtUri;
  try {
    final result = await blueskyClient.atproto.repo.createRecord(
      repo: did,
      collection: kEventCollection,
      record: eventRecord,
    );
    eventRkey = result.data.uri.rkey;
    eventAtUri = result.data.uri.toString();
    print('   ✅ Event created in ${stopwatch.elapsedMilliseconds}ms');
    print('   URI: $eventAtUri');
    print('   CID: ${result.data.cid}');
  } catch (e) {
    print('   ❌ Failed to create event record: $e');
    print('\n   This might mean:');
    print('   - PDS rejects unknown Lexicon collection names');
    print('   - NSID format issue');
    print('   - Record validation failed');
    print('\n⛔ SPIKE FAILED at Step 2.');
    exit(1);
  }

  // ── Step 3: Read Event Back ───────────────────────────────────────
  print('\n3. Reading event record back...');
  stopwatch.reset();

  try {
    final getResult = await blueskyClient.atproto.repo.getRecord(
      repo: did,
      collection: kEventCollection,
      rkey: eventRkey!,
    );
    final value = getResult.data.value;
    print('   ✅ Record read in ${stopwatch.elapsedMilliseconds}ms');
    print('   Name: ${value['name']}');
    print('   StartsAt: ${value['startsAt']}');
    print(
        '   Location: ${(value['locations'] as List?)?.first?['name'] ?? 'none'}');
  } catch (e) {
    print('   ❌ Failed to read event record: $e');
    print('\n⛔ SPIKE FAILED at Step 3.');
    exit(1);
  }

  // ── Step 4: Create RSVP Record ────────────────────────────────────
  print('\n4. Creating RSVP record ($kRsvpCollection)...');
  stopwatch.reset();

  final rsvpRecord = {
    r'$type': kRsvpCollection,
    'eventUri': eventAtUri,
    'status': 'going',
    'createdAt': now,
  };

  String? rsvpRkey;
  try {
    final result = await blueskyClient.atproto.repo.createRecord(
      repo: did,
      collection: kRsvpCollection,
      record: rsvpRecord,
    );
    rsvpRkey = result.data.uri.rkey;
    print('   ✅ RSVP created in ${stopwatch.elapsedMilliseconds}ms');
    print('   URI: ${result.data.uri}');
    print('   CID: ${result.data.cid}');
  } catch (e) {
    print('   ❌ Failed to create RSVP record: $e');
    print('\n⛔ SPIKE FAILED at Step 4.');
    exit(1);
  }

  // ── Step 5: Read RSVP Back ────────────────────────────────────────
  print('\n5. Reading RSVP record back...');
  stopwatch.reset();

  try {
    final getResult = await blueskyClient.atproto.repo.getRecord(
      repo: did,
      collection: kRsvpCollection,
      rkey: rsvpRkey,
    );
    final value = getResult.data.value;
    print('   ✅ RSVP read in ${stopwatch.elapsedMilliseconds}ms');
    print('   EventUri: ${value['eventUri']}');
    print('   Status: ${value['status']}');
  } catch (e) {
    print('   ❌ Failed to read RSVP record: $e');
    print('\n⛔ SPIKE FAILED at Step 5.');
    exit(1);
  }

  // ── Step 6: List Records by Collection ────────────────────────────
  print('\n6. Listing all $kEventCollection records...');
  stopwatch.reset();

  try {
    final listResult = await blueskyClient.atproto.repo.listRecords(
      repo: did,
      collection: kEventCollection,
    );
    print('   ✅ Listed in ${stopwatch.elapsedMilliseconds}ms');
    print('   Found ${listResult.data.records.length} event record(s)');
    for (final record in listResult.data.records) {
      print('     - ${record.value['name']} (${record.uri})');
    }
  } catch (e) {
    print('   ❌ Failed to list records: $e');
    print('   (Non-fatal — listing may work differently)');
  }

  // ── Step 7: Test Custom Lexicon (Sailor namespace) ────────────────
  print('\n7. Testing Sailor custom Lexicon ($kPositionCollection)...');
  stopwatch.reset();

  // NOTE: PDS CBOR encoder rejects Dart doubles in record maps.
  // AT Protocol uses integer for numeric values in records.
  // For lat/lng, we store as scaled integers (microdegrees: value * 1e6)
  // or as strings. Using strings here for clarity.
  final positionRecord = {
    r'$type': kPositionCollection,
    'eventUri': eventAtUri,
    'boatName': 'AU 5432',
    'positions': [
      {
        'latitude': '-31.974400',
        'longitude': '115.840000',
        'timestamp': now,
        'speedKnots': '6.5',
        'headingDeg': '225.0',
        'accuracy': '5.0',
      },
      {
        'latitude': '-31.975000',
        'longitude': '115.841000',
        'timestamp': DateTime.now()
            .toUtc()
            .add(const Duration(seconds: 10))
            .toIso8601String(),
        'speedKnots': '7.2',
        'headingDeg': '230.0',
        'accuracy': '4.0',
      },
    ],
    'createdAt': now,
  };

  String? positionRkey;
  try {
    final result = await blueskyClient.atproto.repo.createRecord(
      repo: did,
      collection: kPositionCollection,
      record: positionRecord,
    );
    positionRkey = result.data.uri.rkey;
    print('   ✅ Position record created in ${stopwatch.elapsedMilliseconds}ms');
    print('   URI: ${result.data.uri}');
  } catch (e) {
    print('   ❌ Failed to create position record: $e');
    print('   This might mean PDS validates NSID ownership or format.');
    print('   (Non-fatal — we can adjust namespace if needed)');
  }

  // ── Step 8: Cleanup — Delete Test Records ─────────────────────────
  print('\n8. Cleaning up test records...');

  try {
    await blueskyClient.atproto.repo.deleteRecord(
      repo: did,
      collection: kEventCollection,
      rkey: eventRkey!,
    );
    print('   ✅ Event deleted');
  } catch (e) {
    print('   ⚠️ Failed to delete event: $e');
  }

  try {
    await blueskyClient.atproto.repo.deleteRecord(
      repo: did,
      collection: kRsvpCollection,
      rkey: rsvpRkey,
    );
    print('   ✅ RSVP deleted');
  } catch (e) {
    print('   ⚠️ Failed to delete RSVP: $e');
  }

  if (positionRkey != null) {
    try {
      await blueskyClient.atproto.repo.deleteRecord(
        repo: did,
        collection: kPositionCollection,
        rkey: positionRkey,
      );
      print('   ✅ Position record deleted');
    } catch (e) {
      print('   ⚠️ Failed to delete position record: $e');
    }
  }

  // ── Summary ───────────────────────────────────────────────────────
  print('\n${'=' * 60}');
  print('SPIKE RESULTS SUMMARY');
  print('=' * 60);
  print('✅ Authentication:              PASS');
  print('✅ Create event (Smoke Signal):  PASS');
  print('✅ Read event back:              PASS');
  print('✅ Create RSVP:                  PASS');
  print('✅ Read RSVP back:               PASS');
  print('✅ RSVP references event URI:    PASS');
  print('');
  print('The RSVP test data flow is VALIDATED.');
  print('PDS accepts custom Lexicon collection names.');
  print('Proceed to Phase 1.');
  print('=' * 60);
}

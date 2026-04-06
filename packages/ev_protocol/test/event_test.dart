import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _pubkey = EvPubkey.fromRawKey('organiser-key');

  group('EvEvent', () {
    EvEvent _createEvent() => EvEvent(
          dhtKey: const EvDhtKey('event-key-1'),
          creatorPubkey: _pubkey,
          name: 'Perth Regatta 2026',
          description: 'Annual sailing regatta',
          startAt: _now,
          endAt: _now,
          location: const EvEventLocation(
            name: 'Fremantle Sailing Club',
            latitude: -32.0569,
            longitude: 115.7439,
            geohash: 'qd66hr',
          ),
          category: 'sailing',
          tags: ['sailing', 'regatta', 'perth'],
          visibility: EvEventVisibility.public_,
          maxCapacity: 200,
          rsvpCount: 42,
          groupDhtKey: const EvDhtKey('group-key-1'),
          createdAt: _now,
          updatedAt: _now,
        );

    test('JSON roundtrip', () {
      final event = _createEvent();
      final json = event.toJson();
      expect(json[r'$type'], 'ev.event.record');
      expect(json[r'$ev_version'], '0.1.0');

      final restored = EvEvent.fromJson(json);
      expect(restored.name, 'Perth Regatta 2026');
      expect(restored.category, 'sailing');
      expect(restored.tags, ['sailing', 'regatta', 'perth']);
      expect(restored.maxCapacity, 200);
      expect(restored.rsvpCount, 42);
      expect(restored.visibility, EvEventVisibility.public_);
    });

    test('location JSON roundtrip', () {
      final event = _createEvent();
      final json = event.toJson();
      final restored = EvEvent.fromJson(json);
      expect(restored.location!.name, 'Fremantle Sailing Club');
      expect(restored.location!.latitude, -32.0569);
      expect(restored.location!.longitude, 115.7439);
      expect(restored.location!.geohash, 'qd66hr');
    });

    test('copyWith', () {
      final event = _createEvent();
      final updated = event.copyWith(
        name: 'Updated Name',
        rsvpCount: 100,
      );
      expect(updated.name, 'Updated Name');
      expect(updated.rsvpCount, 100);
      expect(updated.creatorPubkey, event.creatorPubkey);
    });

    test('minimal event (no optional fields)', () {
      final event = EvEvent(
        creatorPubkey: _pubkey,
        name: 'Simple Event',
        startAt: _now,
        createdAt: _now,
      );
      final json = event.toJson();
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('location'), isFalse);
      expect(json.containsKey('endAt'), isFalse);
      expect(json.containsKey('ticketing'), isFalse);

      final restored = EvEvent.fromJson(json);
      expect(restored.name, 'Simple Event');
      expect(restored.location, isNull);
    });

    test('virtual location', () {
      const loc = EvEventLocation(virtualUrl: 'https://meet.google.com/abc');
      final json = loc.toJson();
      expect(json['virtualUrl'], 'https://meet.google.com/abc');
      final restored = EvEventLocation.fromJson(json);
      expect(restored.virtualUrl, 'https://meet.google.com/abc');
    });
  });

  group('EvEvent with ticketing', () {
    test('full ticketing JSON roundtrip', () {
      final event = EvEvent(
        creatorPubkey: _pubkey,
        name: 'Paid Event',
        startAt: _now,
        createdAt: _now,
        ticketing: EvTicketing(
          model: EvTicketModel.tiered,
          currency: 'AUD',
          tiers: [
            EvTicketTier(name: 'General', priceMinor: 5000, quantity: 100),
            EvTicketTier(name: 'VIP', priceMinor: 15000, quantity: 20),
          ],
          acceptedMethods: [
            const EvPaymentMethod(type: 'stripe', checkoutUrl: 'https://pay.example.com'),
          ],
          refundPolicy: const EvRefundPolicy(
            type: EvRefundType.conditional,
            cutoffHours: 48,
            description: 'Full refund 48hrs before event',
          ),
        ),
      );

      final json = event.toJson();
      final restored = EvEvent.fromJson(json);
      expect(restored.ticketing!.model, EvTicketModel.tiered);
      expect(restored.ticketing!.currency, 'AUD');
      expect(restored.ticketing!.tiers.length, 2);
      expect(restored.ticketing!.tiers[0].name, 'General');
      expect(restored.ticketing!.tiers[0].priceMinor, 5000);
      expect(restored.ticketing!.tiers[1].name, 'VIP');
      expect(restored.ticketing!.refundPolicy!.type, EvRefundType.conditional);
      expect(restored.ticketing!.refundPolicy!.cutoffHours, 48);
      expect(restored.ticketing!.acceptedMethods[0].type, 'stripe');
    });
  });

  group('EvRsvp', () {
    test('JSON roundtrip', () {
      final rsvp = EvRsvp(
        dhtKey: const EvDhtKey('rsvp-key-1'),
        eventDhtKey: const EvDhtKey('event-key-1'),
        attendeePubkey: _pubkey,
        status: EvRsvpStatus.confirmed,
        tierName: 'VIP',
        isPublic: false,
        message: 'Looking forward to it!',
        guestCount: 2,
        createdAt: _now,
      );

      final json = rsvp.toJson();
      expect(json[r'$type'], 'ev.event.rsvp');
      expect(json['status'], 'confirmed');
      expect(json['guestCount'], 2);
      expect(json['isPublic'], false);

      final restored = EvRsvp.fromJson(json);
      expect(restored.status, EvRsvpStatus.confirmed);
      expect(restored.tierName, 'VIP');
      expect(restored.message, 'Looking forward to it!');
      expect(restored.guestCount, 2);
      expect(restored.isPublic, false);
    });

    test('copyWith status change', () {
      final rsvp = EvRsvp(
        eventDhtKey: const EvDhtKey('e1'),
        attendeePubkey: _pubkey,
        status: EvRsvpStatus.pending,
        createdAt: _now,
      );
      final updated = rsvp.copyWith(status: EvRsvpStatus.confirmed);
      expect(updated.status, EvRsvpStatus.confirmed);
      expect(updated.eventDhtKey, rsvp.eventDhtKey);
    });

    test('all RSVP statuses', () {
      for (final status in EvRsvpStatus.values) {
        final rsvp = EvRsvp(
          eventDhtKey: const EvDhtKey('e1'),
          attendeePubkey: _pubkey,
          status: status,
          createdAt: _now,
        );
        final json = rsvp.toJson();
        final restored = EvRsvp.fromJson(json);
        expect(restored.status, status);
      }
    });
  });
}

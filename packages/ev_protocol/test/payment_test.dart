import 'package:test/test.dart';
import 'package:ev_protocol/ev_protocol.dart';

void main() {
  final _now = EvTimestamp.now();
  final _buyer = EvPubkey.fromRawKey('buyer-key');
  final _seller = EvPubkey.fromRawKey('seller-key');

  group('EvPaymentIntent', () {
    test('JSON roundtrip', () {
      final intent = EvPaymentIntent(
        dhtKey: const EvDhtKey('intent-1'),
        eventDhtKey: const EvDhtKey('event-1'),
        buyerPubkey: _buyer,
        tierName: 'General',
        amountMinor: 5000,
        currency: 'AUD',
        paymentMethod: 'stripe',
        status: EvPaymentStatus.pending,
        createdAt: _now,
      );

      final json = intent.toJson();
      expect(json[r'$type'], 'ev.payment.intent');
      expect(json['amountMinor'], 5000);
      expect(json['currency'], 'AUD');
      expect(json['status'], 'pending');

      final restored = EvPaymentIntent.fromJson(json);
      expect(restored.tierName, 'General');
      expect(restored.amountMinor, 5000);
      expect(restored.status, EvPaymentStatus.pending);
    });

    test('copyWith status update', () {
      final intent = EvPaymentIntent(
        eventDhtKey: const EvDhtKey('e1'),
        buyerPubkey: _buyer,
        tierName: 'VIP',
        amountMinor: 15000,
        currency: 'AUD',
        paymentMethod: 'stripe',
        createdAt: _now,
      );
      final updated = intent.copyWith(status: EvPaymentStatus.completed);
      expect(updated.status, EvPaymentStatus.completed);
      expect(updated.amountMinor, 15000);
    });

    test('all payment statuses', () {
      for (final status in EvPaymentStatus.values) {
        final intent = EvPaymentIntent(
          eventDhtKey: const EvDhtKey('e1'),
          buyerPubkey: _buyer,
          tierName: 'T',
          amountMinor: 100,
          currency: 'USD',
          paymentMethod: 'stripe',
          status: status,
          createdAt: _now,
        );
        final json = intent.toJson();
        final restored = EvPaymentIntent.fromJson(json);
        expect(restored.status, status);
      }
    });
  });

  group('EvPaymentReceipt', () {
    test('JSON roundtrip', () {
      final receipt = EvPaymentReceipt(
        dhtKey: const EvDhtKey('receipt-1'),
        eventDhtKey: const EvDhtKey('event-1'),
        buyerPubkey: _buyer,
        sellerPubkey: _seller,
        amountMinor: 5000,
        currency: 'AUD',
        tierName: 'General',
        completedAt: _now,
        proof: const EvPaymentProof(
          type: 'stripe',
          externalId: 'pi_abc123',
          receiptUrl: 'https://receipt.stripe.com/abc',
          sellerSignature: 'seller-sig-123',
        ),
      );

      final json = receipt.toJson();
      expect(json[r'$type'], 'ev.payment.receipt');
      expect(json['proof']['type'], 'stripe');
      expect(json['proof']['externalId'], 'pi_abc123');

      final restored = EvPaymentReceipt.fromJson(json);
      expect(restored.proof.type, 'stripe');
      expect(restored.proof.externalId, 'pi_abc123');
      expect(restored.proof.sellerSignature, 'seller-sig-123');
      expect(restored.amountMinor, 5000);
    });
  });

  group('EvTicket', () {
    test('JSON roundtrip', () {
      final ticket = EvTicket(
        dhtKey: const EvDhtKey('ticket-1'),
        eventDhtKey: const EvDhtKey('event-1'),
        attendeePubkey: _buyer,
        tierName: 'General',
        issuedAt: _now,
        validUntil: EvTimestamp.parse('2026-12-31T23:59:59.000Z'),
        receiptDhtKey: const EvDhtKey('receipt-1'),
        signature: 'organiser-ed25519-signature',
      );

      final json = ticket.toJson();
      expect(json[r'$type'], 'ev.ticket.token');
      expect(json['signature'], 'organiser-ed25519-signature');

      final restored = EvTicket.fromJson(json);
      expect(restored.tierName, 'General');
      expect(restored.signature, 'organiser-ed25519-signature');
      expect(restored.isScanned, isFalse);
      expect(restored.isValid, isTrue);
    });

    test('QR payload', () {
      final ticket = EvTicket(
        eventDhtKey: const EvDhtKey('event-1'),
        attendeePubkey: _buyer,
        tierName: 'VIP',
        issuedAt: _now,
        signature: 'sig-123',
      );

      final qr = ticket.toQrPayload();
      expect(qr['eventDhtKey'], 'event-1');
      expect(qr['attendeePubkey'], _buyer.toString());
      expect(qr['tierName'], 'VIP');
      expect(qr['signature'], 'sig-123');
      expect(qr.containsKey('issuedAt'), isTrue);
    });

    test('isScanned', () {
      final ticket = EvTicket(
        eventDhtKey: const EvDhtKey('e1'),
        attendeePubkey: _buyer,
        tierName: 'T',
        issuedAt: _now,
        signature: 'sig',
        scannedAt: _now,
        scannedBy: _seller,
      );
      expect(ticket.isScanned, isTrue);
    });

    test('isValid with expired ticket', () {
      final ticket = EvTicket(
        eventDhtKey: const EvDhtKey('e1'),
        attendeePubkey: _buyer,
        tierName: 'T',
        issuedAt: _now,
        validUntil: EvTimestamp.parse('2020-01-01T00:00:00.000Z'),
        signature: 'sig',
      );
      expect(ticket.isValid, isFalse);
    });

    test('isValid with no expiry', () {
      final ticket = EvTicket(
        eventDhtKey: const EvDhtKey('e1'),
        attendeePubkey: _buyer,
        tierName: 'T',
        issuedAt: _now,
        signature: 'sig',
      );
      expect(ticket.isValid, isTrue);
    });
  });

  group('EvPaymentMethod', () {
    test('JSON roundtrip', () {
      const method = EvPaymentMethod(
        type: 'crypto',
        destination: 'bc1q...',
        checkoutUrl: 'https://pay.example.com',
      );
      final json = method.toJson();
      final restored = EvPaymentMethod.fromJson(json);
      expect(restored.type, 'crypto');
      expect(restored.destination, 'bc1q...');
    });
  });
}

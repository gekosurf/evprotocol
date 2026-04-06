import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A ticket token for offline QR code verification.
///
/// Schema: `ev.ticket.token`
///
/// The organiser issues a ticket by signing the token fields with their
/// Ed25519 key. At the door, the scanner verifies the signature using
/// the organiser's public key — no network required.
class EvTicket {
  final EvDhtKey? dhtKey;
  final EvDhtKey eventDhtKey;
  final EvPubkey attendeePubkey;
  final String tierName;
  final EvTimestamp issuedAt;
  final EvTimestamp? validUntil;
  final EvDhtKey? receiptDhtKey;
  final String signature;
  final EvTimestamp? scannedAt;
  final EvPubkey? scannedBy;

  const EvTicket({
    this.dhtKey,
    required this.eventDhtKey,
    required this.attendeePubkey,
    required this.tierName,
    required this.issuedAt,
    this.validUntil,
    this.receiptDhtKey,
    required this.signature,
    this.scannedAt,
    this.scannedBy,
  });

  /// Whether this ticket has been scanned at the door.
  bool get isScanned => scannedAt != null;

  /// Whether this ticket is still valid (not expired).
  bool get isValid {
    if (validUntil == null) return true;
    return EvTimestamp.now().isBefore(validUntil!);
  }

  /// Generate a payload for QR code encoding.
  ///
  /// The QR code contains all fields needed for offline verification.
  Map<String, dynamic> toQrPayload() => {
        'eventDhtKey': eventDhtKey.toString(),
        'attendeePubkey': attendeePubkey.toString(),
        'tierName': tierName,
        'issuedAt': issuedAt.toIso8601(),
        'signature': signature,
      };

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.ticket.token',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'attendeePubkey': attendeePubkey.toString(),
        'tierName': tierName,
        'issuedAt': issuedAt.toIso8601(),
        if (validUntil != null) 'validUntil': validUntil!.toIso8601(),
        if (receiptDhtKey != null) 'receiptDhtKey': receiptDhtKey.toString(),
        'signature': signature,
        if (scannedAt != null) 'scannedAt': scannedAt!.toIso8601(),
        if (scannedBy != null) 'scannedBy': scannedBy.toString(),
      };

  factory EvTicket.fromJson(Map<String, dynamic> json) {
    return EvTicket(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      attendeePubkey: EvPubkey(json['attendeePubkey'] as String),
      tierName: json['tierName'] as String,
      issuedAt: EvTimestamp.parse(json['issuedAt'] as String),
      validUntil: json['validUntil'] != null
          ? EvTimestamp.parse(json['validUntil'] as String)
          : null,
      receiptDhtKey: json['receiptDhtKey'] != null
          ? EvDhtKey(json['receiptDhtKey'] as String)
          : null,
      signature: json['signature'] as String,
      scannedAt: json['scannedAt'] != null
          ? EvTimestamp.parse(json['scannedAt'] as String)
          : null,
      scannedBy: json['scannedBy'] != null
          ? EvPubkey(json['scannedBy'] as String)
          : null,
    );
  }
}

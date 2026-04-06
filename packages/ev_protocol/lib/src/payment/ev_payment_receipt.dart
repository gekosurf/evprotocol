import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// Cryptographic proof that a payment was completed.
///
/// Schema: `ev.payment.receipt`
///
/// A receipt is co-signed: the buyer signs it first with their Veilid key,
/// the seller counter-signs after verifying payment with the processor.
class EvPaymentReceipt {
  final EvDhtKey? dhtKey;
  final EvDhtKey eventDhtKey;
  final EvPubkey buyerPubkey;
  final EvPubkey sellerPubkey;
  final int amountMinor;
  final String currency;
  final String tierName;
  final EvTimestamp completedAt;
  final EvPaymentProof proof;

  const EvPaymentReceipt({
    this.dhtKey,
    required this.eventDhtKey,
    required this.buyerPubkey,
    required this.sellerPubkey,
    required this.amountMinor,
    required this.currency,
    required this.tierName,
    required this.completedAt,
    required this.proof,
  });

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.payment.receipt',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'buyerPubkey': buyerPubkey.toString(),
        'sellerPubkey': sellerPubkey.toString(),
        'amountMinor': amountMinor,
        'currency': currency,
        'tierName': tierName,
        'completedAt': completedAt.toIso8601(),
        'proof': proof.toJson(),
      };

  factory EvPaymentReceipt.fromJson(Map<String, dynamic> json) {
    return EvPaymentReceipt(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      buyerPubkey: EvPubkey(json['buyerPubkey'] as String),
      sellerPubkey: EvPubkey(json['sellerPubkey'] as String),
      amountMinor: json['amountMinor'] as int,
      currency: json['currency'] as String,
      tierName: json['tierName'] as String,
      completedAt: EvTimestamp.parse(json['completedAt'] as String),
      proof:
          EvPaymentProof.fromJson(json['proof'] as Map<String, dynamic>),
    );
  }
}

/// Proof linking a protocol receipt to an off-protocol payment.
class EvPaymentProof {
  final String type;
  final String? externalId;
  final String? receiptUrl;
  final String? sellerSignature;

  const EvPaymentProof({
    required this.type,
    this.externalId,
    this.receiptUrl,
    this.sellerSignature,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (externalId != null) 'externalId': externalId,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
        if (sellerSignature != null) 'sellerSignature': sellerSignature,
      };

  factory EvPaymentProof.fromJson(Map<String, dynamic> json) {
    return EvPaymentProof(
      type: json['type'] as String,
      externalId: json['externalId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      sellerSignature: json['sellerSignature'] as String?,
    );
  }
}

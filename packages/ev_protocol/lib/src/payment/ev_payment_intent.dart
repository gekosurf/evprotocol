import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_timestamp.dart';

/// A payment intent — buyer's declaration to pay for an event ticket.
///
/// Schema: `ev.payment.intent`
class EvPaymentIntent {
  final EvDhtKey? dhtKey;
  final EvDhtKey eventDhtKey;
  final EvPubkey buyerPubkey;
  final String tierName;
  final int amountMinor;
  final String currency;
  final String paymentMethod;
  final EvPaymentStatus status;
  final EvTimestamp createdAt;
  final EvTimestamp? updatedAt;

  const EvPaymentIntent({
    this.dhtKey,
    required this.eventDhtKey,
    required this.buyerPubkey,
    required this.tierName,
    required this.amountMinor,
    required this.currency,
    required this.paymentMethod,
    this.status = EvPaymentStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  EvPaymentIntent copyWith({
    EvDhtKey? dhtKey,
    EvPaymentStatus? status,
    EvTimestamp? updatedAt,
  }) {
    return EvPaymentIntent(
      dhtKey: dhtKey ?? this.dhtKey,
      eventDhtKey: eventDhtKey,
      buyerPubkey: buyerPubkey,
      tierName: tierName,
      amountMinor: amountMinor,
      currency: currency,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        r'$type': 'ev.payment.intent',
        if (dhtKey != null) 'dhtKey': dhtKey.toString(),
        'eventDhtKey': eventDhtKey.toString(),
        'buyerPubkey': buyerPubkey.toString(),
        'tierName': tierName,
        'amountMinor': amountMinor,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'status': status.name,
        'createdAt': createdAt.toIso8601(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601(),
      };

  factory EvPaymentIntent.fromJson(Map<String, dynamic> json) {
    return EvPaymentIntent(
      dhtKey:
          json['dhtKey'] != null ? EvDhtKey(json['dhtKey'] as String) : null,
      eventDhtKey: EvDhtKey(json['eventDhtKey'] as String),
      buyerPubkey: EvPubkey(json['buyerPubkey'] as String),
      tierName: json['tierName'] as String,
      amountMinor: json['amountMinor'] as int,
      currency: json['currency'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: EvPaymentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EvPaymentStatus.pending,
      ),
      createdAt: EvTimestamp.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? EvTimestamp.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

enum EvPaymentStatus { pending, processing, completed, failed, refunded, cancelled }

/// Payment method for off-protocol checkout.
class EvPaymentMethod {
  final String type;
  final String? destination;
  final String? checkoutUrl;

  const EvPaymentMethod({
    required this.type,
    this.destination,
    this.checkoutUrl,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (destination != null) 'destination': destination,
        if (checkoutUrl != null) 'checkoutUrl': checkoutUrl,
      };

  factory EvPaymentMethod.fromJson(Map<String, dynamic> json) {
    return EvPaymentMethod(
      type: json['type'] as String,
      destination: json['destination'] as String?,
      checkoutUrl: json['checkoutUrl'] as String?,
    );
  }
}

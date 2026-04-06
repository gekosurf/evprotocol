import '../core/ev_dht_key.dart';
import '../core/ev_pubkey.dart';
import '../core/ev_result.dart';
import 'ev_payment_intent.dart';
import 'ev_payment_receipt.dart';
import 'ev_ticket.dart';

/// Abstract interface for payment coordination in the EV Protocol.
///
/// ```mermaid
/// sequenceDiagram
///     participant Buyer as Buyer App
///     participant Svc as EvPaymentService
///     participant DHT as Veilid DHT
///     participant Stripe as Payment Processor
///     participant Seller as Seller App
///
///     Note over Buyer,Seller: INITIATE PAYMENT
///     Buyer->>Svc: createPaymentIntent(eventKey, tier, method)
///     Svc->>DHT: Write ev.payment.intent {status: pending}
///     Svc-->>Buyer: EvSuccess(EvPaymentIntent)
///
///     Note over Buyer,Seller: EXECUTE PAYMENT (off-protocol)
///     Buyer->>Stripe: Checkout via checkoutUrl
///     Stripe-->>Buyer: Payment succeeded ✓
///
///     Note over Buyer,Seller: RECORD RECEIPT
///     Buyer->>Svc: createReceipt(intentKey, proof)
///     Svc->>DHT: Write ev.payment.receipt
///     Svc->>DHT: Update intent {status: completed}
///     Svc-->>Buyer: EvSuccess(EvPaymentReceipt)
///
///     Note over Buyer,Seller: ISSUE TICKET
///     Seller->>Svc: issueTicket(eventKey, attendeePubkey, tier)
///     Svc->>Svc: Sign token with organiser's key
///     Svc->>DHT: Write ev.ticket.token
///     Svc-->>Seller: EvSuccess(EvTicket)
///
///     Note over Buyer,Seller: VERIFY TICKET (offline)
///     Buyer->>Buyer: Display QR code
///     Seller->>Svc: verifyTicket(qrPayload, organiserPubkey)
///     Svc->>Svc: Verify Ed25519 signature (no network)
///     Svc-->>Seller: EvSuccess(verified: true)
/// ```
abstract class EvPaymentService {
  /// Creates a payment intent for an event ticket.
  Future<EvResult<EvPaymentIntent>> createPaymentIntent({
    required EvDhtKey eventDhtKey,
    required String tierName,
    required int amountMinor,
    required String currency,
    required String paymentMethod,
  });

  /// Gets a payment intent by DHT key.
  Future<EvResult<EvPaymentIntent>> getPaymentIntent(EvDhtKey dhtKey);

  /// Updates the status of a payment intent.
  Future<EvResult<EvPaymentIntent>> updatePaymentStatus({
    required EvDhtKey intentDhtKey,
    required EvPaymentStatus newStatus,
  });

  /// Creates a payment receipt after successful off-protocol payment.
  Future<EvResult<EvPaymentReceipt>> createReceipt({
    required EvDhtKey eventDhtKey,
    required EvPubkey sellerPubkey,
    required int amountMinor,
    required String currency,
    required String tierName,
    required EvPaymentProof proof,
  });

  /// Co-signs a receipt (seller verifies and counter-signs).
  Future<EvResult<EvPaymentReceipt>> coSignReceipt({
    required EvDhtKey receiptDhtKey,
    required String sellerSignature,
  });

  /// Gets a payment receipt by DHT key.
  Future<EvResult<EvPaymentReceipt>> getReceipt(EvDhtKey dhtKey);

  /// Lists all payment receipts for the current user.
  Future<EvResult<List<EvPaymentReceipt>>> listMyReceipts();

  /// Issues a ticket token for an attendee (organiser only).
  ///
  /// Signs the token with the organiser's private key.
  Future<EvResult<EvTicket>> issueTicket({
    required EvDhtKey eventDhtKey,
    required EvPubkey attendeePubkey,
    required String tierName,
    EvDhtKey? receiptDhtKey,
    Duration? validFor,
  });

  /// Verifies a ticket's signature offline.
  ///
  /// No network required — uses the organiser's public key
  /// (pre-loaded in the scanner app) to verify the Ed25519 signature.
  Future<EvResult<bool>> verifyTicket({
    required Map<String, dynamic> qrPayload,
    required EvPubkey organiserPubkey,
  });

  /// Marks a ticket as scanned at the door.
  Future<EvResult<EvTicket>> scanTicket({
    required EvDhtKey ticketDhtKey,
  });

  /// Gets the current user's ticket for an event.
  Future<EvResult<EvTicket?>> getMyTicket(EvDhtKey eventDhtKey);
}

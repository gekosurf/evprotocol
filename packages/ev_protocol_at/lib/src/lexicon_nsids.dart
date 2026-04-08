/// Lexicon collection NSIDs used for AT Protocol record operations.
///
/// Smoke Signal uses `events.smokesignal.calendar.*` for events/RSVPs.
/// Sailor uses `au.sailor.*` for yacht-specific data.
class LexiconNsids {
  LexiconNsids._();

  // ── Smoke Signal Event Lexicon ──────────────────────────────────────
  static const event = 'events.smokesignal.calendar.event';
  static const rsvp = 'events.smokesignal.calendar.rsvp';

  // ── Sailor Custom Lexicons ─────────────────────────────────────────
  static const yachtPosition = 'au.sailor.yacht.position';
  static const yachtTrack = 'au.sailor.yacht.track';
  static const photo = 'au.sailor.photo';
}

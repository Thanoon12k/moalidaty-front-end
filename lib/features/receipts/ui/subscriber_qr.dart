/// QR payload printed on subscriber cards and receipts:
///   `moalidatna://sub/{subscriberId}/gen/{generatorId}`
String subscriberQrData(int subscriberId, int generatorId) => 'moalidatna://sub/$subscriberId/gen/$generatorId';

/// Returns (subscriberId, generatorId), or null when [raw] is not ours.
(int, int)? parseSubscriberQr(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'moalidatna' || uri.host != 'sub') return null;
  final seg = uri.pathSegments;
  if (seg.length != 3 || seg[1] != 'gen') return null;
  final sub = int.tryParse(seg[0]);
  final gen = int.tryParse(seg[2]);
  if (sub == null || gen == null || sub <= 0 || gen <= 0) return null;
  return (sub, gen);
}

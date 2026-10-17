import 'dart:math';

/// Identifier helpers.
///
/// Postgres primary keys in this project are `uuid`, and the app sends the id
/// it generated, so a record created offline must already carry a real UUID.
/// The older `prod_<milliseconds>` style ids were rejected by Postgres with
/// SQLSTATE 22P02 ("invalid input syntax for type uuid"), which broke every
/// remote create. Always mint ids with [uuid].
abstract final class IdGen {
  static final Random _random = Random.secure();

  /// A random RFC 4122 version-4 UUID.
  static String uuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// A short, human-friendly, collision-resistant order number.
  ///
  /// Kept stable for a single checkout attempt: the order row's UUID is what
  /// uniquely identifies the order, the number is only a label.
  static String orderNumber() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final now = DateTime.now().toUtc();
    final stamp = now.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final suffix = List<String>.generate(
      4,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
    return 'ORD-$stamp-$suffix';
  }
}

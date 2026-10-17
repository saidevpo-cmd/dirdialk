/// Normalises and validates customer phone numbers.
///
/// The rule is deliberately format-agnostic — the business serves customers
/// with local and international numbers — so it accepts any number with
/// 7–15 digits, optionally with a leading `+`. `place_order()` in
/// `supabase/migrations/20261015120000_checkout_integrity_social_and_location.sql`
/// enforces exactly the same digit range, so the client and the database can
/// never disagree about what is valid.
abstract final class PhoneNumber {
  static const int minDigits = 7;
  static const int maxDigits = 15;

  /// Digits only (no `+`, spaces, dashes, parentheses).
  static String digits(String input) => input.replaceAll(RegExp(r'\D'), '');

  static bool isValid(String input) {
    final d = digits(input);
    return d.length >= minDigits && d.length <= maxDigits;
  }

  /// Trims, drops disallowed characters and returns either `+<digits>` or
  /// `<digits>`. Returns an empty string when there are no digits at all.
  static String normalize(String input) {
    final plus = input.trimLeft().startsWith('+');
    final d = digits(input);
    if (d.isEmpty) return '';
    return plus ? '+$d' : d;
  }
}

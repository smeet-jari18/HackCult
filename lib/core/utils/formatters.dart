import 'package:intl/intl.dart';

/// Indian number formatting helpers (₹1,00,000 · 12.5 kg · 450 units).
class Fmt {
  Fmt._();

  static final _inr =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _inrDec =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final _int = NumberFormat.decimalPattern('en_IN');

  static String rupees(num v) => _inr.format(v);
  static String rupeesDec(num v) => _inrDec.format(v);
  static String int(num v) => _int.format(v.round());
  static String kg(num v, {IntValue decimals = 1}) =>
      '${v.toStringAsFixed(decimals)} kg';
  static String units(num v) => '${_int.format(v.round())} units';
  static String tonnes(num kg) => '${(kg / 1000).toStringAsFixed(1)} t';
  static String pct(num v, {IntValue decimals = 0}) =>
      '${v.toStringAsFixed(decimals)}%';
  static String compact(num v) =>
      NumberFormat.compact(locale: 'en_IN').format(v);
  static String month(DateTime d) => DateFormat('MMM yyyy').format(d);
  static String monthShort(DateTime d) => DateFormat('MMM').format(d);
  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String dateTime(DateTime d) => DateFormat('d MMM, h:mm a').format(d);

  /// Stable, human-readable GEDA consumer id derived from the auth uid
  /// (display only — the real id comes from the DISCOM link later).
  static String consumerId(String uid) {
    var h = 0;
    for (final c in uid.codeUnits) {
      h = (h * 31 + c) & 0xffff;
    }
    return 'GJ-${1000 + h % 9000}-${String.fromCharCode(65 + h % 26)}';
  }
}

// `Fmt.int` shadows `int` inside the class body, so use an alias for parameter types.
typedef IntValue = int;

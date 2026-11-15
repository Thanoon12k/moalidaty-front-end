/// Lenient JSON readers: Postgres numerics may arrive as int, double or string.
int asInt(Object? v) => switch (v) {
      int i => i,
      num n => n.toInt(),
      String s => int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0,
      _ => 0,
    };

int? asIntOrNull(Object? v) => v == null ? null : asInt(v);

double asDouble(Object? v) => switch (v) {
      num n => n.toDouble(),
      String s => double.tryParse(s) ?? 0,
      _ => 0,
    };

DateTime? asDate(Object? v) =>
    v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;

extension FirstCharacter on String {
  /// First user-perceived character (safe for Arabic and emoji).
  String get characters1 => isEmpty ? '' : String.fromCharCodes(runes.take(1));
}

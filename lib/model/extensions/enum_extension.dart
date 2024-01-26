extension EnumExtension on Enum {
  String get asString => toString().split('.').last;

  static Enum fromString(String string, List<Enum> values) {
    for (var value in values) {
      if (value.asString.toLowerCase() == string.toLowerCase()) {
        return value;
      }
    }
    throw ArgumentError('Invalid token source type string');
  }

  bool isString(String encoding) => encoding.toLowerCase() == asString.toLowerCase();
}

extension EnumExtension on Enum {
  bool isName(String enumName) => enumName == name;
  bool isNameInsensitive(String enumName) => enumName.toLowerCase() == name.toLowerCase();
}

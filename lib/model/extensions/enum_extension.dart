extension EnumExtension on Enum {
  bool isName(String enumName, {bool caseSensitive = true}) => caseSensitive ? name == enumName : name.toLowerCase() == enumName.toLowerCase();
}

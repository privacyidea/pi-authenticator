#!/bin/bash

# Überprüfen, ob das Eingabeargument angegeben wurde
if [ $# -ne 2 ]; then
  echo "Verwendung: $0 <packageName> <appName>"
  exit 1
fi
packageName="$1"
appName="$2"
file="ios/Runner.xcodeproj/project.pbxproj"
# Überprüfen, ob die Datei existiert
if [ ! -f "$file" ]; then
  # Fehlermeldung ausgeben, wenn die Datei nicht gefunden wurde
  echo "Die Datei '$file' wurde nicht gefunden. Führen Sie den befehl im projekt root aus."
fi
echo "Die Datei '$file' wird bearbeitet..."  
# Die Zeichenkette in der Datei suchen und ersetzen
sed -i "s/\(PRODUCT_BUNDLE_IDENTIFIER = \)[^;]*\(;\)/\1$packageName\2/" "$file"
sed -i "s/\(PRODUCT_NAME = \)[^;]*\(;\)/\1$appName\2/" "$file"

echo "... Die Datei '$file' wurde bearbeitet."

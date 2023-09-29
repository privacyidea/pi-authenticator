#!/bin/bash

# Überprüfen, ob das Eingabeargument angegeben wurde
if [ $# -ne 1 ]; then
  echo "Verwendung: $0 <appName>"
  exit 1
fi
appName=$1
file="ios/Runner/Info.plist"
# Überprüfen, ob die Datei existiert
if [ ! -f "$file" ]; then
  # Fehlermeldung ausgeben, wenn die Datei nicht gefunden wurde
  echo "Die Datei '$file' wurde nicht gefunden. Führen Sie den befehl im projekt root aus."
fi
echo "Die Datei '$file' wird bearbeitet..."
# Die Zeichenkette in der Datei suchen und ersetzen
sed -i "/<key>CFBundleName<\/key>/ { N; s/<key>CFBundleName<\/key>\n\s*<string>[^<]*<\/string>/<key>CFBundleName<\/key>\n    <string>$appName<\/string>/ }"  "$file"

echo "... Die Datei '$file' wurde bearbeitet."
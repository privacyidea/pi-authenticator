#!/bin/bash

# Überprüfen, ob das Eingabeargument angegeben wurde
if [ $# -ne 1 ]; then
  echo "Verwendung: $0 <customizationJson>"
  exit 1
fi
customizationJson=$1
file="lib/utils/app_customizer.dart"
# Überprüfen, ob die Datei existiert
if [ ! -f "$file" ]; then
  # Fehlermeldung ausgeben, wenn die Datei nicht gefunden wurde
  echo "Die Datei '$file' wurde nicht gefunden. Führen Sie den befehl im projekt root aus."
fi
echo "Die Datei '$file' wird bearbeitet..."  
# Die Zeichenkette in der Datei suchen und ersetzen
sed -i "s/\(const String customization = \)[^;]*\(;\)/\1'$customizationJson'\2/" "$file"
echo "... Die Datei '$file' wurde bearbeitet."

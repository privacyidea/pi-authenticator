#!/bin/bash
# Überprüfen, ob die Datei existiert
if [ $# -ne 2 ]; then
  echo "Verwendung: $0 <packageName> <appName>"
  exit 1
fi
packageName=$1
appName=$2
if [[ ! -f "android/app/src/main/AndroidManifest.xml" ||  ! -f "android/app/src/debug/AndroidManifest.xml"  || ! -f "android/app/src/profile/AndroidManifest.xml"  ]]; then
  # Fehlermeldung ausgeben, wenn eine Datei nicht gefunden wurde
  echo "Eine "AndroidManifest.xml" datei wurde nicht gefunden. Führen Sie den befehl im projekt root aus."
  exit 1
fi
echo "Die AndroidManifest.xml Dateien werden bearbeitet..."
# Die Zeichenkette in der Datei suchen und ersetzen, und Rückgabewert prüfen
sed -i "s/\(package=\"\)[^\"]*\(\"\)/\1$packageName\2/" android/app/src/main/AndroidManifest.xml
sed -i "s/\(android:label=\"\)[^\"]*\(\"\)/\1$appName\2/" android/app/src/main/AndroidManifest.xml
sed -i "s/\(package=\"\)[^\"]*\(\"\)/\1$packageName\2/" android/app/src/debug/AndroidManifest.xml
sed -i "s/\(package=\"\)[^\"]*\(\"\)/\1$packageName\2/" android/app/src/profile/AndroidManifest.xml
echo "... Die AndroidManifest.xml Dateien wurden bearbeitet."
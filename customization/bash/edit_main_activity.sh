#!/bin/bash

# Überprüfen, ob das Eingabeargument angegeben wurde
if [ $# -ne 1 ]; then
  echo "Verwendung: $0 <packageName>"
  exit 1
fi
find kotlin -type d ! -path "kotlin/it/netknights/piauthenticator" -exec rm -rf {} \;

file_name="MainActivity.kt"
original_file="android/app/src/main/kotlin/it/netknights/piauthenticator/$file_name"

echo "Die Datei '$original_file' wird kopiert..."
packageName="$1"
IFS="."
read -a packageArray <<< "$packageName"
IFS=" "

main_activity_folder="android/app/src/main/java"
for folder in "${packageArray[@]}"; do
  main_activity_folder="$main_activity_folder/$folder"
done

new_file="$main_activity_folder/$file_name"

echo "... neue Datei '$new_file' wird erstellt..."

mkdir -p "$main_activity_folder"
cp "$original_file" "$new_file"
sed -i "s/package it.netknights.piauthenticator/package $packageName/" "$new_file"

echo "... kopieren abgeschlossen und bearbeiten abgeschlossen."
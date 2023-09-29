#!/bin/bash

################################
######### FUNCTIONS  ###########
################################
function generate_key_properties_and_jks() {
  echo "Generating key.properties and $company.jks..."
  random_password=$(openssl rand -base64 20 | tr -d '=')
  if [ -f "$key_properties_file" ]; then
    > "$key_properties_file"
  fi
  echo "storePassword=$random_password" >> "$key_properties_file"
  echo "keyPassword=$random_password" >> "$key_properties_file"
  echo "keyAlias=app-signing-key" >> "$key_properties_file"
  echo "storeFile=$company.jks" >> "$key_properties_file"
  
  if [ -f "$key_store_file" ]; then
    rm "$key_store_file"
  fi
  keytool -genkey -v -keystore "$key_store_file" -keyalg RSA -keysize 2048 -validity 10000 -alias app-signing-key -storepass $random_password -keypass $random_password -dname "CN=., OU=., O=NetKnights GmbH, L=Kassel, ST=Hessen, C=DE"
  echo "...key.properties and $company.jks successfully generated."
}

function check_google_service_files(){
  if [ ! -f "$google_services_file" ]; then
    echo "$google_services_file not found"
    exit 1
  fi
  if [ ! -f "$google_service_info_file" ]; then
    echo "$google_service_info_file not found"
    exit 1
  fi
}

function check_customisation_file(){
  if [ ! -f "$customisation_file" ]; then
    echo "$customisation_file not found"
    exit 1
  fi
}

function check_and_get_package_name(){
  if [ -f "$company_folder/package_name.txt" ]; then
    packageName=$(cat "$package_name_file")
  fi
  if [ -z "$packageName" ]; then
    echo "No packagename found. Please enter a package name for &company. e.g. it.netknights.authenticator"
    read packagename
    if [ -z "$packagename" ]; then
      echo "No packagename entered. Aborting..."
      exit 1
    fi
    echo "$packagename" > "$package_name_file"
  fi 
}

function check_key_properties_and_key_store_file(){
  if [[ ! -f "$key_properties_file" || ! -f "$key_store_file" ]]; then
    echo "$key_properties_file or $key_store_file not found"
    echo "Do you want to create them? (y/n)"
    read answer
    if [ "$answer" == "y" ]; then
      generate_key_properties_and_jks
    else
      echo "Aborting..."
      exit 1
    fi
  fi
}

function copy_google_service_files(){
  echo "Copying google service files..."
  if [ ! -d "android/app/src/release" ]; then
    mkdir -p "android/app/src/main"
  fi
  if [ ! -d "ios/Runner" ]; then
    mkdir -p "ios/Runner"
  fi
  cp "$google_services_file" "android/app/src/release"
  cp "$google_services_file" "android/app/src/debug"
  sed -i "s|$package_name|$package_name.debug|" "android/app/src/debug/google-services.json"
  cp "$google_service_info_file" "ios/Runner"
  echo "Google service files successfully copied."
}

# Den Wert von appIconBytes extrahieren, decodieren und in eine Datei schreiben
function create_launcher_icons_from_customisation_file(){
  if [ ! -d "$temp_dir" ]; then
  mkdir -p "$temp_dir"
  fi
  echo $(jq -r '.appIconBytes' "$customisation_file") | base64 --decode > "$app_icon"
  if [ ! -f "$app_icon" ]; then
    echo "Fehler beim Erstellen der Datei '$app_icon'."
    exit 1
  fi
  echo "$app_icon erfolgreich aus $customisation_file extrahiert."

  echo "Erstelle launcher icons..."
  magick "$app_icon" -alpha set -background none -gravity center -extent 150% "$app_icon_adaptive"
  dart run flutter_launcher_icons
  if [ $? -ne 0 ]; then
    echo "Fehler beim Erstellen der launcher icons."
    exit 1
  fi
  echo "...launcher icons erfolgreich erstellt."
}

function move_appbundle() {
if [ ! -d "$output_folder" ]; then
  mkdir -p "$output_folder"
fi

if [ -f "$output_folder/app-release.aab" ]; then
  rm "$output_folder/app-release.aab"
fi

mv build/app/outputs/bundle/release/app-release.aab "$output_folder/$appName_release.aab"

echo "Appbundle successfully created for $company and moved to $output_folder/$appName_release.aab"
}

function clean_up_temp() {
  rm -r "$temp_dir"
}

################################
############ MAIN  #############
################################
cd "$(dirname "$0")"

# Überprüfen, ob das Eingabeargument angegeben wurde
if [ $# -ne 1 ]; then
  echo "Verwendung: $0 <folder> #folder of the respective company with the customization files must be in the folder customization"
  exit 1
fi
company="$1"
base_folder="customization"
company_folder="$base_folder/$company"
output_folder="./build_outputs"

google_services_file="$company_folder/google-services.json"
google_service_info_file="$company_folder/GoogleService-Info.plist"
customisation_file="$company_folder/customisation_file.json"
key_properties_file="$company_folder/key.properties"
key_store_file="$company_folder/$company.jks"
package_name_file="$company_folder/package_name.txt"

temp_dir="$base_folder/temp"
app_icon_adaptive="$temp_dir/app_icon_adaptive.png"
app_icon="$temp_dir/app_icon.png"

check_google_service_files
check_customisation_file
check_and_get_package_name
check_key_properties_and_key_store_file
copy_google_service_files
create_launcher_icons_from_customisation_file

appName=$(jq -r '.appName' "$customisation_file")

echo "Package name: $packageName, App name: $appName"

./customization/bash/edit_android_manifest.sh "$packageName" "$appName"
./customization/bash/edit_app_customizer.sh "$customizationJson"
./customization/bash/edit_build_gradle.sh "$packageName"
./customization/bash/edit_project_pbxproj.sh "$packageName" "$appName"
./customization/bash/edit_info_plist.sh "$appName"
./customization/bash/edit_main_activity.sh "$packageName"

flutter build appbundle

move_appbundle 
clean_up_temp

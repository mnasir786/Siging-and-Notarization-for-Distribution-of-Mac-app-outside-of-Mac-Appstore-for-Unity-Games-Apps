#!/bin/bash

# Set variables
AppName="GameName" # this will be the name of you app/game
KeychainProfile="KeychainProfileName" # Replace with the name of your keychain profile see reedme to see how to create this.
ApplicationCertificateName="DeveloperName (xxxxxxxxxx)" # replce xxxxxxxxxx with you team id. replace DeveloperName with you develoepr name
identifier="com.company.appname" # this will be you bundle identifier for this app/game

# Set path to your application
apppath="./$AppName.app"

# Grant read permissions to the application
echo "Granting Read Permissions to App... $apppath"
chmod -R a+xr "$apppath"

# Sign the application
echo "Signing Application..." # here you should sign all the /Frameworks & libraries & plugins
codesign -f --deep --options=runtime -s "Developer ID Application: $ApplicationCertificateName" --entitlements "./entitleFile.entitlements" "$apppath/Contents/Frameworks/GameAssembly.dylib"
codesign -f --deep --options=runtime -s "Developer ID Application: $ApplicationCertificateName" --entitlements "./entitleFile.entitlements" "$apppath/Contents/Frameworks/UnityPlayer.dylib"
codesign -f --deep --options=runtime -s "Developer ID Application: $ApplicationCertificateName" --entitlements "./entitleFile.entitlements" "$apppath/Contents/MacOS/Glassman"
codesign -f --deep --options=runtime -s "Developer ID Application: $ApplicationCertificateName" --entitlements "./entitleFile.entitlements" "$apppath/"

# Package the application into a .pkg file
echo "Packaging Application..."
pkgbuild --root "$apppath" --install-location "/Applications/$AppName.app" --identifier "${identifier}" --sign "Developer ID Installer: $ApplicationCertificateName" "$AppName.pkg"

# Sign the application package
echo "Signing Application Package..."
productsign --sign "Developer ID Installer: $ApplicationCertificateName" "$AppName.pkg" "$AppName-signed.pkg"

echo "Creating .dmg file..."
dmg_filename="$AppName-installer.dmg"
hdiutil create -volname "$AppName" -srcfolder "$AppName-signed.pkg" -ov -format UDZO "$dmg_filename"

echo "Installer .dmg created: $dmg_filename"

# Should continue the Request ContinueNotarizing:
read -p "Should continue the Request ContinueNotarizing: " ContinueNotarizing

# Notarize the application package
echo "Notarizing Application Package... $ContinueNotarizing"
notarization_output=$(xcrun notarytool submit --keychain-profile "$KeychainProfile" "$dmg_filename")

echo "Notarization Output:"
echo "$notarization_output"


# Prompt the user to enter the request UUID
echo "Please enter the Request UUID:$request_uuid"
read request_uuid

# Check if request_uuid is not empty
if [ -n "$request_uuid" ]; then
    echo "Request UUID: $request_uuid"
    
    # Check notarization status
    echo "Checking Notarization Status..."
    status="In Progress"
    while [ "$status" != "Accepted" ]; do
        notarization_info=$(xcrun notarytool info --keychain-profile "$KeychainProfile" "$request_uuid")
        echo "$notarization_info"
        echo "Enter Status:"
        read status
        if [ "$status" == "Accepted" ]; then
            echo "Notarization Status: $status"
        elif [ "$status" == "Invalid" ]; then
            echo "Notarization Status: $status"
            xcrun notarytool log --keychain-profile "$KeychainProfile"  "$request_uuid" # show logs..
            exit 1
        else
            echo "Notarization Status: $status"
        fi
    done
    
    xcrun notarytool log --keychain-profile "$KeychainProfile"  "$request_uuid" # show logs..
    # Staple the package
    echo "Stapling the .dmg file..."
    xcrun stapler staple "$dmg_filename"
    # xcrun stapler staple "$AppName-signed.pkg"
    # Eject the disk image
    echo "Unmounting the disk image..."
    hdiutil eject "/Volumes/$AppName"
    
else
    echo "Error: Failed to extract RequestUUID from notarization output."
fi
# Siging-and-Notarization-for-Distribution-of-Mac-app-outside-of-Mac-Appstore-for-Unity-Games-Apps
Siging and Notarization for Distribution of Mac app outside of Mac Appstore for Unity Games &amp; Apps

This project is shared with you so that you can easily sign, signed package and create disk images and then notarize them to submit your apps/games outside of mac appstore.

1-  Put you GameName.app folder in same folder where this script is located.

2- Store a profile which will be used in the script later... make sure you create an app specific password.
xcrun notarytool store-credentials KeychainProfileName --apple-id apple_id_email@gmail.com --password app_specific_password  --team-id your_team_id 

3- After assigning all the required variables in first few lines just run this script in your Terminal or(zsh) using following command 

./SignAndNotarize.sh

I will add more details or feel free to ask me if you need help at admin@riwada.com

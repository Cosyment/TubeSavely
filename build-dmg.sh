#!/bin/sh
create-dmg \
  --volname "Application Installer" \
  --volicon "/Users/Waiting/AndroidStudioProjects/TubeSavely/build/macos/Build/Products/Release/TubeSavely.app/Contents/Resources/AppIcon.icns" \
  --background "/Users/Waiting/AndroidStudioProjects/TubeSavely/assets/images/ic_feedback.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "/Users/Waiting/AndroidStudioProjects/TubeSavely/assets/ic_logo.png" 200 190 \
  --hide-extension "TubeSavely.app" \
  --app-drop-link 600 185 \
  "/Users/Waiting/AndroidStudioProjects/TubeSavely/build/macos/TubeSavely.dmg" \
  "/Users/Waiting/AndroidStudioProjects/TubeSavely/build/macos/Build/Products/Release/TubeSavely.app/"
#"Application-Installer.dmg"是.dmg文件名称。
#"source_folder/"是"flutter build macos --release"结果路径，如：/工程目录/build/macos/Build/Products/Release/xxx.app


hdiutil create -srcfolder build/macos/Build/Products/Release/TubeSavely.app TubeSavely.dmg
hdiutil convert TubeSavely.dmg -format UDBZ -o Compressed_TubeSavely.dmg

#!/bin/sh
# 检查是否存在 Application-Installer.dmg 文件，如果存在则删除
#if [ -f Application-Installer.dmg ]; then
#    rm Application-Installer.dmg
#fi
#
#test -f Application-Installer.dmg && rm Application-Installer.dmg
#create-dmg \
#  --volname "Application Installer" \
#  --volicon "build/macos/Build/Products/Release/TubeSavely.app/Contents/Resources/AppIcon.icns" \
#  --background "assets/images/ic_feedback.png" \
#  --window-pos 200 120 \
#  --window-size 800 400 \
#  --icon-size 100 \
#  --icon "assets/ic_logo_small.png" 200 190 \
#  --hide-extension "TubeSavely.app" \
#  --app-drop-link 600 185 \
#  "build/macos/TubeSavely.dmg" \
#  "build/macos/Build/Products/Release/TubeSavely.app"

hdiutil create -srcfolder build/macos/Build/Products/Release/TubeSavely.app TubeSavely.dmg
hdiutil convert TubeSavely.dmg -format UDBZ -o Compressed_TubeSavely.dmg

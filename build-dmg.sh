#!/bin/sh
set -e

# 设置变量
APP_NAME="TubeSavely"  # 你的应用名称
APP_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')  # 从pubspec.yaml读取版本号
FLUTTER_PROJECT_PATH="/Users/Waiting/AndroidStudioProjects/TubeSavely"  # Flutter项目路径，当前目录
BUILD_PATH="${FLUTTER_PROJECT_PATH}/build/macos/Build/Products/Release"  # 构建输出路径
APP_PATH="${BUILD_PATH}/${APP_NAME}.app"  # 应用的完整路径
ICON_PATH="${APP_PATH}/Contents/Resources/AppIcon.icns"  # 应用图标路径
DMG_NAME="${APP_NAME}_${APP_VERSION}.dmg"  # DMG文件名
DMG_PATH="${BUILD_PATH}/${DMG_NAME}"  # DMG文件存放路径
TMP_DIR=$(mktemp -d)  # 创建临时目录

# 确保应用已经构建
echo "确保macOS应用已经构建在路径：${APP_PATH}"
if [ ! -d "${APP_PATH}" ]; then
  echo "构建macOS应用..."
  cd "$FLUTTER_PROJECT_PATH" || exit
  flutter build macos --release
fi

# 复制.app文件到临时目录
echo "复制应用文件到临时目录..."
cp -R "${APP_PATH}" "${TMP_DIR}"

# 进入临时目录
cd "${TMP_DIR}" || exit

# 使用create-dmg创建DMG
echo "使用create-dmg创建DMG文件：${DMG_NAME}"
create-dmg \
  --volname "${APP_NAME}" \
  --window-size 800 400 \
  --background "$FLUTTER_PROJECT_PATH/assets/images/ic_feedback.png" \
  --icon-size 100 \
  --text-size 12 \
  --icon "${APP_NAME}.app" 200 150 \
  --app-drop-link 600 150 \
  "${DMG_PATH}" \
  "${APP_NAME}.app"

# 清理临时目录
echo "清理临时文件..."
cd "$FLUTTER_PROJECT_PATH" || exit
rm -rf "${TMP_DIR}"

echo "DMG打包完成：${DMG_PATH}"
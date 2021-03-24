#!/usr/bin/env bash

# 这个脚本的作用是打包上传到App Store上.

git checkout ${branch}
git pull

echo "---设置版本号---"
APP_VERSION=${app_version}
APP_BUILD=${app_build}
agvtool new-marketing-version ${APP_VERSION}
agvtool new-version -all ${APP_BUILD}

echo "Linux提权"
sudo spctl --master-disable # 已经设置过了etc/sudoers无需输入sudo密码

echo "设置编译路径"
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

WORKSPACE_NAME=xxxx
SCHEME_NAME=xxxx
ARCHIVE_PATH=xxxx
ENVIRONMENT_BUILD=Release
UPLOAD_PLIST=/Users/mini/Desktop/Release/upload_appstore.plist

echo "---执行clean---"
xcodebuild clean -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME}

echo "---clean完毕，编译---"
xcodebuild -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME} -sdk iphoneos -configuration ${ENVIRONMENT_BUILD} -archivePath ${ARCHIVE_PATH}/${SCHEME_NAME}.xcarchive archive

if [ "${uploadToApple}" = true ]
then
    echo "---需要上传到Apple store---"
       echo "---编译成app完毕，进行打包上传App Store---"
       xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH}/${SCHEME_NAME}.xcarchive -exportPath ${ARCHIVE_PATH}/${SCHEME_NAME} -exportOptionsPlist ${UPLOAD_PLIST}
       echo "---上传到AppStore完毕---"
else
    echo "---不需要上传到Apple store---"
fi


#/bin/bash
# 这个脚本的作用是导出ipa，然后上传到Fir.im上.

SCHEME_NAME=xxxx
ARCHIVE_PATH=xxxx
ENVIRONMENT_BUILD=Release

EXPORT_PLIST=/Users/mini/Desktop/Release/export_appstore.plist

echo "--- 导出ipa包，用以上传到蒲公英 ---"
xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH}/${SCHEME_NAME}.xcarchive -exportPath ${ARCHIVE_PATH}/${SCHEME_NAME} -exportOptionsPlist ${EXPORT_PLIST}

echo "---进入到ipa的文件夹"
cd ${ARCHIVE_PATH}/${SCHEME_NAME}

IPA_PATH=${SCHEME_NAME}.ipa
API_KEY=xxxx

echo "push 上传到 蒲公英"
curl -F "file=@${IPA_PATH}" -F "_api_key=${API_KEY}" https://www.pgyer.com/apiv2/app/upload

echo "上传成功"

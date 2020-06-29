
#/bin/bash

git checkout ${branch}
git pull

echo "---设置版本号---"
APP_VERSION=${app_version}
APP_BUILD=${app_build}
agvtool new-marketing-version ${APP_VERSION}
agvtool new-version -all ${APP_BUILD}

echo "--- pod 安装---"
#pod install

echo "Linux提权"
sudo spctl --master-disable # 已经设置过了etc/sudoers无需输入sudo密码

echo "设置编译路径"
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

WORKSPACE_NAME=xxxx
SCHEME_NAME=xxxx
ARCHIVE_PATH=../../jobs/${JOB_NAME}/builds/${BUILD_NUMBER}
ENVIRONMENT_BUILD=Debug
EXPORT_PLIST=/Users/mini/Desktop/Development/ExportOptions_development.plist

echo "---执行clean---"
xcodebuild clean -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME}

echo "---clean完毕，编译---"
xcodebuild -workspace ${WORKSPACE_NAME}.xcworkspace -scheme ${SCHEME_NAME} -sdk iphoneos -configuration ${ENVIRONMENT_BUILD} -allowProvisioningUpdates -archivePath ${ARCHIVE_PATH}/${SCHEME_NAME}.xcarchive archive

echo "---编译成app完毕，进行打包---"
xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH}/${SCHEME_NAME}.xcarchive -exportPath ${ARCHIVE_PATH}/${SCHEME_NAME} -exportOptionsPlist ${EXPORT_PLIST} -allowProvisioningUpdates

echo "---打包完毕---"

echo "---进入到打包文件夹"

cd ${ARCHIVE_PATH}/${SCHEME_NAME}

#echo "登录到 fir.im"
#login 后面是API TOKEN
#fir login xxxx

#echo "push 上传到 fir.im"
#fir publish ${SCHEME_NAME}.ipa

#echo "上传成功"

IPA_PATH=xxxx
API_KEY=xxxx

echo "push 上传到 蒲公英"
curl -F "file=@${IPA_PATH}" -F "_api_key=${API_KEY}" https://www.pgyer.com/apiv2/app/upload

echo "上传成功"

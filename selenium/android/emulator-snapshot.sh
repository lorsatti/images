#!/bin/bash
MAX_ATTEMPTS=5
adb root
adb devices | grep emulator | cut -f1 | while read id; do
    apks=(/usr/bin/*.apk)
    for apk in "${apks[@]}"; do
        if [ -r "$apk" ]; then
            for i in `seq 1 ${MAX_ATTEMPTS}`; do
                echo "Installing $apk (attempt #$i of $MAX_ATTEMPTS)"
                adb -s "$id" install -r "$apk" && break || sleep 15 && echo "Retrying to install $apk"
            done
        fi
    done
    java -Xmx1024M -Xss1m -jar /opt/android-sdk-linux/build-tools/29.0.2/lib/apksigner.jar sign \
        --key /opt/node_modules/appium/node_modules/appium-adb/keys/testkey.pk8 \
        --cert /opt/node_modules/appium/node_modules/appium-adb/keys/testkey.x509.pem \
        /opt/node_modules/appium/node_modules/appium-uiautomator2-server/apks/appium-uiautomator2-server-debug-androidTest.apk
    adb -s "$id" install -g /opt/node_modules/appium/node_modules/io.appium.settings/apks/settings_apk-debug.apk
    adb -s "$id" install -r /opt/node_modules/appium/node_modules/appium-uiautomator2-server/apks/appium-uiautomator2-server-v*.apk
    adb -s "$id" install -r /opt/node_modules/appium/node_modules/appium-uiautomator2-server/apks/appium-uiautomator2-server-debug-androidTest.apk
    adb -s "$id" emu kill -2 || true
done
rm -f /tmp/.X99-lock || true

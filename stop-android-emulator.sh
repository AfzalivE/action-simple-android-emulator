#!/bin/bash

# Copied from https://github.com/mindrunner/docker-android-sdk/blob/master/tools/android-wait-for-emulator.sh
# Modified with logic from 

set +e

$ANDROID_SDK_ROOT/platform-tools/adb -s emulator-5554 emu kill

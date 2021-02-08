#!/bin/bash

# Copied from https://github.com/mindrunner/docker-android-sdk/blob/master/tools/android-wait-for-emulator.sh
# Modified with changes from https://github.com/ReactiveCircus/android-emulator-runner/blob/main/src/emulator-manager.ts

set -ex

bootcompleted=""
failcounter=0
timeout=600
sleeptime=10
maxfail=$((timeout / sleeptime))

until [[ "${bootcompleted}" =~ "1" ]]; do
    bootcompleted=`$ANDROID_SDK_ROOT/platform-tools/adb -e shell getprop sys.boot_completed 2>&1 &`
    if [[ "${bootcompleted}" =~ "" ]]; then
        ((failcounter += 1))
        echo "Waiting for emulator to start"
        if [[ ${failcounter} -gt ${maxfail} ]]; then
            echo "Timeout ($timeout seconds) reached; failed to start emulator"
            while pkill -9 "emulator" >/dev/null 2>&1; do
                echo "Killing emulator proces...."
                pgrep "emulator"
            done
            echo "Process terminated"
            pgrep "emulator"
            exit 1
        fi
    fi
    sleep ${sleeptime}
done

echo "Emulator is ready"

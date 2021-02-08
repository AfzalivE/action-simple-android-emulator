#!/bin/bash

# Starts an Android emulator using the specified sdk and device.
# The emulator is setup to improve test reliability and reduce flakiness, by ensuring it doesn't lock itself,
# increasing the long-press delay, and disabling animations, spellchecker, IME keyboard and autofill service.

# Copied from https://github.com/Doist/PipelinesTemplates/blob/master/step-android-start-emulator.yml

set -ex

SDK=29
DEVICE=pixel
TIMEOUT=10

echo "Downloading Android emulator image $SDK"
echo 'y' | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --install "system-images;android-$SDK;google_apis;x86_64"

echo "Creating AVD"
echo 'no' | $ANDROID_SDK_ROOT/tools/bin/avdmanager create avd -n "emulator-$SDK" -d "$DEVICE" -k "system-images;android-$SDK;google_apis;x86_64" -f

echo "Enable hardware keyboard"
printf 'hw.keyboard = yes\n' >> ~/.android/avd/"emulator-$SDK.avd"/config.ini

echo "Starting AVD"
nohup $ANDROID_SDK_ROOT/emulator/emulator -avd "emulator-$SDK" -no-snapshot -no-boot-anim -no-audio -no-window -delay-adb >/dev/null 2>&1 &

echo "Waiting for AVD to start"
sleep 1
# Print emulator version.
$ANDROID_SDK_ROOT/emulator/emulator -version | head -n 1
# Print running devices.
$ANDROID_SDK_ROOT/platform-tools/adb devices

./android-wait-for-emulator.sh

echo "Keeping power on, disabling animations, spell checker, and autofill."
# set it up: ensure it's on, disable animations, ime, spell checker and autofill.
$ANDROID_SDK_ROOT/platform-tools/adb </dev/null wait-for-device shell '
  svc power stayon true;
  settings put global window_animation_scale 0;
  settings put global transition_animation_scale 0;
  settings put global animator_duration_scale 0;
  settings put secure long_press_timeout 1500;
  settings put secure show_ime_with_hard_keyboard 0;
  settings put secure spell_checker_enabled 0;
  settings put secure autofill_service null;
  input keyevent 82;'

  echo "Emulator ready"

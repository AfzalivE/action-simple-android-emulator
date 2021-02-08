# Starts an Android emulator using the specified sdk and device.
# The emulator is setup to improve test reliability and reduce flakiness, by ensuring it doesn't lock itself,
# increasing the long-press delay, and disabling animations, spellchecker, IME keyboard and autofill service.

# Copied from https://github.com/Doist/PipelinesTemplates/blob/master/step-android-start-emulator.yml

SDK=29
DEVICE=pixel
TIMEOUT=10

echo "starting emulator API $SDK"

# Download image and create emulator.
echo 'y' | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --install "system-images;android-$SDK;google_apis;x86_64"
echo 'no' | $ANDROID_SDK_ROOT/tools/bin/avdmanager create avd -n "emulator-$SDK" -d "$DEVICE" -k "system-images;android-$SDK;google_apis;x86" -f
# Ensure hardware keyboard configuration is enabled, and set 1GB of RAM.
printf 'hw.keyboard = yes\n' >> ~/.android/avd/"emulator-$SDK.avd"/config.ini
# Start emulator.
nohup $ANDROID_SDK_ROOT/emulator/emulator -avd "emulator-$SDK" -no-snapshot -no-boot-anim -no-audio -no-window -delay-adb >/dev/null 2>&1 &
# Wait for it to start.
sleep 1
# Print emulator version.
$ANDROID_SDK_ROOT/emulator/emulator -version | head -n 1
# Print running devices.
$ANDROID_SDK_ROOT/platform-tools/adb devices
# Wait for the device, and set it up: ensure it's on, disable animations, ime, spell checker and autofill.
$ANDROID_SDK_ROOT/platform-tools/adb </dev/null wait-for-device shell '
  ./android-wait-for-emulator.sh
  svc power stayon true;
  settings put global window_animation_scale 0;
  settings put global transition_animation_scale 0;
  settings put global animator_duration_scale 0;
  settings put secure long_press_timeout 1500;
  settings put secure show_ime_with_hard_keyboard 0;
  settings put secure spell_checker_enabled 0;
  settings put secure autofill_service null;
  input keyevent 82;'

  echo "Start emulator for API $SDK"

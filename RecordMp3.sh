#!/bin/bash

# Original duration: 10 * 60 -1 = 599
MINUTES="${1}"
GRACE=5 # Seconds of grace allowed between recordings, to avoid missing the whole duration due to device conflict.
let SECS="${MINUTES} * 60 - ${GRACE}"

# Original dir: /home/pi/WAVs
DESTDIR="${2}"
mkdir -p "${DESTDIR}"

# Original mic: hw:1
MICROPHONE="${3}"

# Original format: S16_LE
FORMAT="U8"

### User feedback:
# Turn off the LED to indicate the device is busy by setting it not to trigger on anything. (reverts to static setting of brightness, default 0)
echo none | sudo tee /sys/class/leds/led0/trigger > /dev/null

/usr/bin/ffmpeg -t "${SECS}" -f alsa -ac 1 -ar 44100 -i "${MICROPHONE}" -acodec libmp3lame -f mp3 pipe:1  2> /dev/null | /home/pi/encrypt.sh "${DESTDIR}"/`date -Iseconds`.mp3.gpg 2> /dev/null
sync

# Restore previous (activity and power) function of the LED.  This means the LED should be on when the mic is not recording.
echo actpwr | sudo tee /sys/class/leds/led0/trigger > /dev/null

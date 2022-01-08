#!/bin/bash

# Original duration: 10 * 60 -1 = 599
MINUTES="${1}"
GRACE=5 # Seconds of grace allowed between recordings, to avoid missing the whole duration due to device conflict.
let SECONDS="${MINUTES} * 60 - ${GRACE}"

# Original dir: /home/pi/WAVs
DESTDIR="${2}"
mkdir -p "${DESTDIR}"

# Original mic: hw:1
MICROPHONE="${3}"

# Original format: S16_LE
FORMAT="U8"

/usr/bin/ffmpeg -t "${SECONDS}" -f alsa -ac 1 -ar 44100 -i "${MICROPHONE}" -acodec libmp3lame -f mp3 pipe:1  2> /dev/null | /home/pi/encrypt.sh "${DESTDIR}"/`date -Iseconds`.mp3.gpg 2> /dev/null
sync


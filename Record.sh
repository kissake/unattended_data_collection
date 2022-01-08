#!/bin/bash

# Original duration: 10 * 60 -1 = 599
MINUTES="${1}"
let SECONDS="${MINUTES} * 60 - 1"

# Original dir: /home/pi/WAVs
DESTDIR="${2}"
mkdir -p "${DESTDIR}"

# Original mic: hw:CARD=WEBCAM,DEV=0
MICROPHONE="${3}"

arecord --format=S16_LE --rate=16000 --file-type=wav -d "${SECONDS}" -D "${MICROPHONE}" 2> /dev/null | /home/pi/encrypt.sh "${DESTDIR}"/`date -Iseconds`.wav.gpg 2> /dev/null
sync


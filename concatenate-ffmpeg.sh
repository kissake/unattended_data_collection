#!/bin/bash

TARGET="${1}"
shift

ALLFILE="concat:${1}"
shift

for file in "${@}"
do
	ALLFILE="${ALLFILE}|${file}"
done

ffmpeg -i "${ALLFILE}" -acodec copy "${TARGET}"

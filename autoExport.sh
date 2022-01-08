#!/bin/bash

DEBUG="${1}"
MOUNTPOINT=/media/usb0/
FILENAME="WAVs.zip"    # This is appended directly to the mountpoint to get the destination filename.
SOURCE=/home/pi/WAVs/
DELAY=1 # in seconds
POSTCOPYDELAY=20 # in seconds

while true
do 
	if [ "${DEBUG}x" == "debugx" ] ; then echo "Started checking for mounted filesystem." ; fi
	while ! mountpoint -q "${MOUNTPOINT}"
	do
		sleep ${DELAY}
	done

	if [ "${DEBUG}x" == "debugx" ] ; then echo "Found a mounted filesystem, copying." ; fi

	### User feedback to indicate that the USB drive was found and we are copying data.
	# Turn off the LED by setting it not to trigger on anything. (reverts to static setting of brightness, default 0)
	echo none | sudo tee /sys/class/leds/led0/trigger > /dev/null

	cd "${SOURCE}"
	sudo zip -q -n gpg "${MOUNTPOINT}${FILENAME}" *
	sudo /usr/bin/umount "${MOUNTPOINT}"
	sync
	if [ "${DEBUG}x" == "debugx" ] ; then echo "Finished copying, unmounted." ; fi

	# Restore previous (activity and power) function of the LED
	echo actpwr | sudo tee /sys/class/leds/led0/trigger > /dev/null

	### DISABLED
	### Use this code to turn on and off the LED if you need a pattern of some sort
	# echo 1 | sudo tee /sys/class/leds/led0/brightness > /dev/null
	# echo 0 | sudo tee /sys/class/leds/led0/brightness > /dev/null
	### DISABLED

	# Prevent an out-of-control cycle time if we are unable to unmount the drive.
	sleep ${POSTCOPYDELAY}

	
done



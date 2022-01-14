# Unattended Data Collection

This is a project intended to support unattended data collection in a way that protects the data being collected.

Specifically, there are two parts:
 - Collect data that is of some use (e.g. audio, video, GPS, accelerometer)
 - Encrypt it on local storage so to limit the risk to privacy if the media is exposed.  Ideally it is never stored on disk unencrypted.
 - Provide means for retrieving the data and decrypting it.

The initial project is aimed at audio recording using a Raspberry Pi Zero (simple, low hanging fruit), with the intention of being extensible for other uses.

## Example

Example use case (functionality existing today):
 - Generate key pair
 - Set up Raspberry Pi device (hardware and this software required!)
 - Power on Raspberry Pi with USB microphone attached.
 - Leave device powered for and arbitrary amount of time in a place where you expect to hear interesting things.
 - Unplug the microphone.
 - Plug in a USB stick.
 - Remove USB stick when the light turns on, and take to the computer where you generated the key pair to decrypt.

## Features

Features:
 - Continuous recording most of the time the microphone is connected.
 - Data stored encrypted using the public key stored on the device.  An attacker that obtains the device does not have access to recordings that occurred before they gained access.
 - Automatically copies data to the USB stick when plugged in.
 - Automatically starts recording again after (not when) microphone plugged in again.
 - Fully functional without network connectivity, with caveats (below: Caveats section)

## Motivation

I want to see if I am waking up in the middle of the night due to noises, or ...? 

To do that, I need to record data (audio) in a private context (e.g. a bedroom) in such a way that that the audio can be reviewed at a later time, but:
 - ONLY BY the person responsible for that context (e.g. me), and
 - ONLY IF that person takes active steps to do so (e.g. decrypt, when I decide to do so because I got woken up!!)

I don't want my pillow-talk to fall into someone else's hands without my consent.

A future enhancement is to permit encryption such that all N persons who might have a privacy interest in the audio must consent.
 - Perhaps sharding?
 - But since it is 'all', simply sequentially encrypting with all, wrapping with one after the other.

This raises an interesting concept w/r/t privacy, FWIW.  If we wanted to do this at huge scale, how might we do it?  
 - Bluetooth broadcast of a public key using badges / IDs / phones?  Combined with
 - Automatically include public keys of those recognized as being in the vicinity?
 - How to handle people who show up in the middle of a recording period? (stop, start with new set of keys?)

## Requirements

In this form, you'll want:
 - a Raspberry Pi (Zero is fine for this use) which means you will also want:
   * Micro-SD card capable of containing 1 day's audio and the baseline Raspbian: about 4GB is fine.
   * A power supply for it.  They apparently are picky.  I found an iPhone plug-in USB charger that works, but they sell these specifically.  YMMV.
   * A Micro-USB (male) to USB-A (female) adapter.
 - A microphone (I'm actually using a cheap webcam which comes with a mic.  The mic sucks, but it's good enough.)
 - A USB drive capable of containing 1 day's audio (1/4 GB?  If you can buy it today, it can hold a day's audio)

## Installation or Getting Started

### Get this data
You can get this software here from GitHub.  Lots of tutorials on that part.

### Install Raspberry Pi OS and make it accessible via ssh
I did the Raspberry OS install without beneift of HDMI, USB keyboard, etc. by following directions here: https://thedatafrog.com/en/articles/raspberry-pi-zero-headless-install/
 - I found this article helpful: https://github.com/raspberrypi/firmware/issues/1184
 - I may create a tool to automate this part at some point; not there yet.
 - Do an update + upgrade so you're up-to-date OS-wise.

### unattended_data_collection setup

I created the public / private key pair using the setup.sh script.  You should name them 'audio', or update the crontab file with the new name.  It requires a password (a pair of passwords?) for the private key.

### Install collection tools

I copied data to the Raspberry Pi 'pi' user's home directory using scp:
 - autoExport.sh
 - CleanupOldWAVs.sh
 - crontab
 - decryptMult.sh
 - encrypt.sh
 - lighttpd.conf
 - RecordMp3.sh
 - audio.pubkey

### Install software dependencies

I installed the relevant software:
 - Note that gpg and arecord (if you want to use that instead) are already installed in the default build.
 - ffmpeg
   * You need this if you want to output .mp3 files.  This gains you a factor of 5-10 w/r/t storage, which also decreases the time required to copy data off.  Big win.
 - zip
   * This helps put the files onto a VFAT filesystem; I put colons in the names, and they are v. long, so... not very FAT friendly.
- usbmount 
   * You need this to enable the automatic copying of files to a USB drive.  Lighttpd is another option to get data off of it.  See below for some necessary steps for getting this working.
 - lighttpd
   * An alternative tool for pulling the data off.  Non-SSL, but this lack of encryption is mitigated by the fact that the data itself is already encrypted.

#### usbmount notes

You will probably (as of this writing) find that 

  `systemctl show --property=PrivateMounts systemd-udevd.service`

shows the output:

  `PrivateMounts=yes`

In my experience, this means the USB drive won't correctly mount to /media/usb0/ when connected.  Ideally, you could fix this with the command:

  `systemctl set-property systemd-udevd.service PrivateMounts=no`

However, due to systemd, we can't have nice things (I may file a bug report, but I'm open to hearing why I'm wrong).  Instead, you'll need to edit the file with the command:

  `sudo systemctl edit systemd-udevd.service`

And add the following two lines near the top of the file, between the two relevant comments: "### Anything between here and "... and "### Lines below this "...

```
[Service]
PrivateMounts=no
```

Putting them below the second comment is an exercise in futility.

### Activate the data collection

The active collection / function runs through cron.  The recordings are kicked off every 10 minutes on the 0'th minute, and the tool to copy data to the USB drive is run on reboot and continues until it crashes.

Next, install the crontab as the 'pi' user:

  `crontab crontab`

Make sure to check in on the usbmount notes below, and then reboot to activate the automatic exporting of data when you plug in the USB drive:

  `sudo reboot`


## Usage

Example use case (functionality existing today):

 - Take Pi + mic to place to record
 - Plug in, wait for status LED to go off to indicate recording (should be ~ 5 minutes +/- 5 minutes)
 - Ignore until something happens you want to hear.
 - Unplug mic, plug in USB stick, and wait for the light to come on.
 - Unplug USB stick and plug in the mic again, waiting for the light to go out.
 - Repeat!

## Caveats

In the situation where there is no wireless access, the clock on the system is not going to be updated using
NTP.  Instead it will only update using the normal builtin clock, along with the fake-hwtime feature (on the
Raspberry Pi), which uses state recorded on disk to try to enforce monotonically increasing time.

Because of this platform's lack of many features we often take for granted, it is possible, if not likely,
that 1) the system will spend significant amounts of time without power, and 2) that the system will not
maintain an external system clock (e.g. using a CMOS battery or similar), and 3) that the system will likely
be shut down uncleanly (preventing the update of fake-hwclock).

While the system will work to mitigate this in part by reporting the number of boots detected, along with the
time relative to the most recent boot, in this situation it would be wise to take some step to record the 
current time at some point after recording has begun.  One way to do this would be by speaking the current 
time within range of the microphone.
    
## Reference

+ Shoulders of giants
+ https://thedatafrog.com/en/articles/raspberry-pi-zero-headless-install/
+ https://github.com/raspberrypi/firmware/issues/1184
+ Any number of articles and man pages about ffmpeg, usbmount, systemd, gpg.

## Contributors

Just me so far, but I'm open to help.  I'm new to git / GitHub, so please be gentle.  

I know there are a LOT of things to clean up, and I am not 100% on the cryptography part.  I know it works in a few ways:
 - Probably encrypted because zip absolutely refused to compress the WAV files I sent through this process, even when they were mostly silence.
 - Going through gpg encrypt and gpg decrypt has expected results (illegible after encrypt, useful after decrypt), but I don't actually know the algorithms, etc. in use, nor why I need to enter the password twice (yet).

There are also lots of hardcoded things that need cleaning up.

## License

This is being released under GNU General Public License version 3.  License information to be updated in relevant files before long.

Of course, only my contributions are so licensed.  I believe the files in this GitHub project are exclusively my own work with the exception of some crontab boilerplate.  
I am making use of Debian as my base / baseline; this would have gone no-where without the great folks working on that project / in that community.

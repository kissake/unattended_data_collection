#!/usr/bin/python3

# Needed for running subprocesses
import os
import subprocess
import argparse

# File containing the ratchet state.
ratchetFileDefault="~/.clockratchet"

# Uptime file.
uptimeFileName = "/proc/uptime"


def arguments():

    parser = argparse.ArgumentParser(
        description="Return monotonically increasing time related information for use in identifiers")
    parser.add_argument(
        '--ratchet',
        action='store_true',
        help='Increment the ratchet value, and produce no output.  This is intended for use on boot')
    parser.add_argument(
        '--file',
        dest='ratchetFile',
        default=ratchetFileDefault,
        help='Indicate the file to store the ratchet data in.  Default value is: %s' % (ratchetFileDefault))
    parser.add_argument(
        '--label',
        dest='label',
        default=None,
        help='Add a label string to be included in the output to disambiguate if needed')
    return parser.parse_args()


def getRelTime():
    # Get years, weeks, days, hours, minutes, seconds since boot.

    # Extract number of seconds since boot from /proc/uptime
    uptimeFile = open(uptimeFileName,"r")
    uptimeData = uptimeFile.read()
    (secs, trash) = uptimeData.split(' ')

    # Separate number of seconds of uptime into time units using the uptime format:
    # Uptime format (reverse of below): seconds, minutes, hours, days, weeks, years.
    uptimeParsing = [60, 60, 24, 7, 52]
    curr = int(float(secs))
    values = []
    for increment in uptimeParsing:
        values.append(curr % increment)
        next = curr // increment
        curr = next
    values.append(curr)
    values.reverse()

    # Format value text into years, weeks, days, 
    valueText="-".join(["%02d" % val for val in values])
    
    return valueText


def getNTPSyncTime():
    # Get current time if NTPSynchronized, or return false otherwise.
    timeDateOutput = subprocess.check_output(['/usr/bin/timedatectl','show'])
    timeDateValues=timeDateOutput.split(b'\n')
    # print(timeDateValues)
    if b'NTPSynchronized=yes' in timeDateValues:
        for value in timeDateValues:
            if value.startswith(b'TimeUSec'):
                (trash, dateTime) = value.decode('utf-8').split('=')
                (trash, date, time, tz) = dateTime.split(" ")
                time.replace(":"," ")
                return "_".join([date, time, tz])
    
    # Time not synchronized or unable to interpret time.
    return False


def getRatchet(ratchetFileName=None):
    # Get the current value of the ratchet/counter, default to zero (0)
    try:
        
        if ratchetFileName is None:
            ratchetFile = open(ratchetFileDefault,'r')
        else:
            ratchetFile = open(ratchetFileName,'r')

        # retrieve and return current ratchet value
        currentRatchet = int(ratchetFile.read())
        return currentRatchet
    
    except FileNotFoundError:
        print("The ratchet file may not have been created yet.  Please check to ensure %s has been created using the --ratchet argument to this command" % (ratchetFileName))
        raise

    except ValueError:
        print("The ratchet file may have been corrupted.  You can overwrite the contents of %s using the --ratchet argument to this command" % (ratchetFileName))
        raise
        
    
    
def ratchet(ratchetFileName=None):
    # Increment the locally stored counter (typically boot counter)
    oldRatchetValue = getRatchet(ratchetFileName)
    newRatchetValue = oldRatchetValue+1
    ratchetFile = open(ratchetFileName,'w')
    ratchetFile.write(str(newRatchetValue))


if __name__ == "__main__":
    args = arguments()
    print(args)
    if args.ratchet:
        ratchet(args.ratchetFile)
    else:
        ratchetValue=getRatchet(args.ratchetFile)
        if args.label is not None:
            ratchetText="%s--%s" % (args.label, ratchetValue)
        else:
            ratchetText=ratchetValue
            
        relTimeValue=getRelTime()

        timeSyncValue=getNTPSyncTime()
        
        if timeSyncValue != False:
            print("%s+%s--%s" % (ratchetText, relTimeValue, timeSyncValue))
        else:
            print("%s+%s" % (ratchetValue, relTimeValue))

        

#!/bin/bash

find /home/pi/WAVs/ -mtime +0 -print0 | xargs -0 -r rm

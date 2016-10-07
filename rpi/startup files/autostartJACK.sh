#!/bin/sh
sleep 10
su root -c "/home/pi/bin/Playback_to_Lineout.sh -d"
sleep 1
su root -c "/home/pi/bin/Record_from_lineIn_Micbias.sh -d"
sleep 1
su root -c "jackd -P75 -dalsa -dhw:0 -p2048 -n8 -s -r44100"

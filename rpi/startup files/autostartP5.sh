#!/bin/sh
sleep 15
export DISPLAY=:1
sleep 1
su root -c " processing-java --sketch=/home/pi/Desktop/cdm_2_2_5 --output=/home/pi/Desktop/p5output --force --run"

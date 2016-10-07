#!/bin/sh
sleep 35
export DISPLAY=:1
sleep 1
su root -c "sclang -D /home/pi/Desktop/cdm_2_2_5/main_2_09.scd"

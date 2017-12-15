#!/bin/sh
#sleep 5
#su root -c "Xvfb :1 -screen 0 1024x768x24"

ping -c4 www.google.com > /dev/null
 
while [ $? != 0 ] 
do
  echo "No network connection, restarting wlan0"
  /sbin/ifdown 'wlan0'
  sleep 5
  /sbin/ifup --force 'wlan0'
  sleep 30
  ping -c4 www.google.com > /dev/null
done

sleep 5
echo "start programs"
/bin/bash /home/pi/autostartXvfb.sh
sleep 10
/bin/bash /home/pi/autostartJACK.sh
sleep 15
. /home/pi/autostartP5.sh
sleep 20
. /home/pi/autostartSC.sh

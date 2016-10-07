#!/bin/sh
sleep 5
su root -c "Xvfb :1 -screen 0 1024x768x24"

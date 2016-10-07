#!/bin/bash
su root -c "pkill jackd" && su root -c "pkill sclang"
sleep 10
sudo halt

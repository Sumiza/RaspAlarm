#!/bin/bash
#------Settings--------

ArmingTime=15
usedpins=(14 15)

#----------------------

function system_armed_once {
     echo "ARMED NOW"
     sleep 0.5
     # do stuff here when alarm activates, runs once.
}

function system_disarmed_once {
     echo "Disarmed now"
     sleep 1.0
# do stuff here when alarm deactivates, runs once.
}

function system_armed {
#    echo "Armed"
     while [ "$arm" -ge 0 ]; do

             echo "$arm"
             ((arm=arm-1))
             sleep 0.5
             if [ "$arm" -eq -1 ]; then
                 system_armed_once
             fi
     done

     if [ "$arm" -eq -1 ]; then
         echo "ARMED"
         cat /sys/class/gpio/gpio4/value
     fi
}

function system_disarmed {

     if [ "$arm" -eq -1 ]; then
         system_disarmed_once
     fi
     echo "Not Armed"
     arm=$ArmingTime
}

arm=$ArmingTime
for i in "${usedpins[@]}"; do
        raspi-gpio set "$i" ip pd
        echo "$i" > /sys/class/gpio/export
        echo "in" > /sys/class/gpio/gpio"$i"/direction
done

while :
do
         if [ -f "armed" ]; then

             system_armed
         else
             system_disarmed
         fi
     sleep 1
done

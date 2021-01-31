#!/bin/bash
#------Settings--------

ArmingTime=15
DisarmTime=10
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
     while [ "$ArmingTime" -ge 0 ]; do

             echo "$ArmingTime"
             ((ArmingTime=ArmingTime-1))
             sleep 0.5
             if [ "$ArmingTime" -eq -1 ]; then
                 system_armed_once
             fi
     done

     if [ "$ArmingTime" -eq -1 ]; then
         echo "ARMED"
         for i in "${usedpins[@]}"; do 
                trigger=$(cat /sys/class/gpio/gpio"$i"/value)
                 if [ "$trigger" = "1" ]; then
                       alarm_trigger
                       break
                fi
         done
     fi
}

function system_disarmed {

     if [ "$ArmingTime" -eq -1 ]; then
         system_disarmed_once
     fi
     echo "Not Armed"
     ArmingTime=15
}

function alarm_trigger {
        echo "alarm triggered..."
        while [ $DisarmTime -ge 0 ]; do
                if [ -f "armed" ]; then
                        echo "$DisarmTime" till Alarm
                        ((DisarmTime=DisarmTime-1))
                        sleep 1
                else
                        system_disarmed
                        DisarmTime=10
                fi
                if [ $DisarmTime -eq 0 ]; then
                        echo "TRIGGER REAL ALARM"
                        rm alarm
                        sleep 1
                fi
        done
}

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

#!/bin/bash

#--- Load Settings from Alarm.conf

source alarm.conf
Beeppin=$Beep_Noise_Pin
Doording=$Door_Ding_Pin
NumberBeeps=$Number_Of_Beeps
BeepLength=$Length_Of_Beep


opendoortoggle=1
function Beep_on {
        echo "0" > /sys/class/gpio/gpio"$Beeppin"/value
}
function Beep_off {
        echo "1" > /sys/class/gpio/gpio"$Beeppin"/value
}
while :
do
        if ! ls Armed* > /dev/null 2>&1; then
        opendoor=$(cat /sys/class/gpio/gpio"$Doording"/value)
                if [ "$opendoor" != "$opendoortoggle" ] && [ "$opendoor" = "1" ]; then
                        for ((n=0;n<NumberBeeps;n++))
                        do
                                Beep_on
                                sleep "$BeepLength"
                                Beep_off
                                sleep "$BeepLength"
                        done
                        opendoortoggle=1
                elif [ "$opendoor" = "0" ]; then
                        opendoortoggle=0
                fi
        fi
        sleep 0.5
done

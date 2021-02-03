#!/bin/bash
#------Settings--------

ArmingTime=15
DisarmTime=10
usedpins=(14 15)
TimeBetweenMessage=50

#----------------------

function system_armed_once {
      echo "ARMED NOW"
      sleep 1.0
      # do stuff here when alarm activates, runs once.
}

function system_disarmed_once {
      echo "Disarmed now"
      sleep 1.0
# do stuff here when alarm deactivates, runs once.
}

function alarm_trigger {
         echo "TRIGGER ALARM !!!!"
         sendcount=$TimeBetweenMessage
         while [  -f "armed"  ]; do
                 echo $sendcount
                 #ring siren
                 if [ $sendcount -eq $TimeBetweenMessage ] || [ $sendcount -eq 0 ]; then
                         echo "sending message and calling"
                         sendcount=$TimeBetweenMessage
                 fi
                 ((sendcount=sendcount-1))
                 sleep 1.0

         done
         system_disarmed
}

function system_armed {
         while [ "$arm" -ge 0 ]; do
                 if [ -f "armed" ]; then
                      echo "$arm"
                      ((arm=arm-1))
                      sleep 1
                          if [ "$arm" -eq -1 ]; then
                                 system_armed_once
                         fi
                 else
                         arm=-1
                         system_disarmed
                         break 1
                 fi
         done

         if [ "$arm" -eq -1 ]; then
                 echo "ARMED"
                 for i in "${usedpins[@]}"; do
                         trigger=$(cat /sys/class/gpio/gpio"$i"/value)
                         if [ "$trigger" = "1" ]; then
                                alarm_countdown
                                break 1
                         fi
                  done
         fi

}

function system_disarmed {

      if [ "$arm" -eq -1 ]; then
         system_disarmed_once
         if [ -f "armed" ]; then
                 rm armed
         fi
         arm=$ArmingTime
         dis=$DisarmTime
      fi
      echo "Not Armed"
}

function alarm_countdown {
         echo "alarm countdown..."
         while [ "$dis" -ge 0 ]; do
                 if [ -f "armed" ]; then
                         echo "$dis" till Alarm
                         ((dis=dis-1))
                         if [ "$dis" -eq 0 ]; then
                                 alarm_trigger
                                 break 1
                         fi
                         sleep 1
                 else
                         system_disarmed
                         break 1
                 fi
         done
}

arm=$ArmingTime
dis=$DisarmTime
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

#!/bin/bash

#--- Load Settings from Alarm.conf

source Alarm.conf
ArmingTime=$Arming_Time
DisarmTime=$Disarm_Time
usedpins=($Used_Pins)
TimeBetweenMessage=$Time_Between_Message
PhoneNrsArm=($Phone_Numbers_Arm)
PhoneNrsDis=($Phone_Numbers_Disarm)
PhoneNrsAlarm=($Phone_Numbers_Alarm)
VoipMSDID=$VoipMS_DID
VoipMSAPIUser=$VoipMS_API_User
VoipMSAPIPass=$VoipMS_API_Password


#echo $ArmingTime
#echo $DisarmTime
#echo $usedpins
#echo $TimeBetweenMessage
#echo "$PhoneNrs"

if [ "$ArmingTime" = "" ] || [ "$DisarmTime" = "" ] || [ "$ArmingTime" = "" ] || [ "$DisarmTime" = "" ]; then
         echo "CANT LOAD CONFIG FILE EXITING"
         exit 1
fi

function send_sms {
         curl -X GET "https://voip.ms/api/v1/rest.php?api_username=$VoipMSAPIUser&api_password=$VoipMSAPIPass&method=sendSMS&did=$VoipMSDID&dst=$1&message=$2"
}

#-----Done Loading-----------

function system_armed_once {
       echo "ARMED NOW"
       for i in "${PhoneNrsArm[@]}"; do
                 echo "calling armed $i"
                 send_sms "$i" "ECO_Alarm_Armed"
       done
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
                  echo "$sendcount"
                  #ring siren
                  if [ "$sendcount" -eq "$TimeBetweenMessage" ] || [ "$sendcount" -eq 0 ]; then
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
                          if [ "$trigger" = "0" ]; then
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
          echo "Activating Pin $i"
          raspi-gpio set "$i" ip pu
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
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

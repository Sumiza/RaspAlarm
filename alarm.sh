#!/bin/bash

#--- Load Settings from Alarm.conf

source alarm.conf
ArmingTime=$Arming_Time
DisarmTime=$Disarm_Time
SensorPins=($Sensor_Pins)
TimeBetweenMessage=$Time_Between_Message
PhoneNrsArm=($Phone_Numbers_Arm)
PhoneNrsDis=($Phone_Numbers_Disarm)
PhoneNrsAlarm=($Phone_Numbers_Alarm)
TwilioSID=$Twilio_SID
TwilioAT=$Twilio_AH
TwilioDiD=$Twilio_DID
Red_led=$Led_Red
Green_led=$Led_Green


if [ "$ArmingTime" = "" ] || [ "$DisarmTime" = "" ] || [ "$ArmingTime" = "" ] || [ "$DisarmTime" = "" ]; then
         echo "CANT LOAD CONFIG FILE EXITING"
         exit 1
fi
#-----Done Loading-----------

function send_sms {
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/"$TwilioSID"/Messages.json \
        --data-urlencode "Body=$2" \
        --data-urlencode "From=$TwilioDiD" \
        --data-urlencode "To=$1" \
        -u "$TwilioSID":"$TwilioAT"
}

function system_armed_once {
       echo "ARMED NOW"
       for i in "${PhoneNrsArm[@]}"; do
                 echo "SMS Sent to armed $i"
                 send_sms "$i" "Alarm_Armed"
       done
       sleep 1.0
       # do stuff here when alarm activates, runs once.
}

function system_disarmed_once {
       echo "Disarmed now"
       for i in "${PhoneNrsDis[@]}"; do
                 echo "SMS sent to disarmed $i"
                 send_sms "$i" "Alarm_Disarmed"
       done
       sleep 1.0
# do stuff here when alarm deactivates, runs once.
}

function alarm_trigger {
          echo "TRIGGER ALARM !!!!"
          sendcount=$TimeBetweenMessage
          while ls armed* > /dev/null 2>&1; do
                  echo "$sendcount"
                  #ring siren
                if [ "$red" = "1" ]; then
                        Red_off
                else
                        Red_on
                fi
                  if [ "$sendcount" -eq "$TimeBetweenMessage" ] || [ "$sendcount" -eq 0 ]; then
                        echo "sending message and calling"
                        for i in "${PhoneNrsAlarm[@]}"; do
                                echo "SMS sent to ALARM $i"
                                send_sms "$i" "Alarm_Triggered_On_Pin_$1"
                        done
                        sendcount=$TimeBetweenMessage
                  fi
                  ((sendcount=sendcount-1))
                  sleep 1.0

          done
          system_disarmed
}

function system_armed {
          while [ "$arm" -ge 0 ]; do
                  if ls armed* > /dev/null 2>&1; then
                       echo "$arm"
                       if [ "$red" = "1" ]; then
                                Red_off
                       else
                                Red_on
                       fi
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
                  for i in "${SensorPins[@]}"; do
                          trigger=$(cat /sys/class/gpio/gpio"$i"/value)
                          if [ "$trigger" = "1" ]; then
                                 alarm_countdown "$i"
                                 break 1
                          fi
                   done
          fi
}

function system_disarmed {

       if [ "$arm" -eq -1 ]; then
          system_disarmed_once
          if ls armed* > /dev/null 2>&1; then
                  rm armed*
          fi
          arm=$ArmingTime
          dis=$DisarmTime
       fi
       echo "Not Armed"
}

function alarm_countdown {
          echo "alarm countdown..."
          while [ "$dis" -ge 0 ]; do
                  if ls armed* > /dev/null 2>&1; then
                          echo "$dis" till Alarm
                          ((dis=dis-1))
                          if [ "$dis" -eq 0 ]; then
                                  alarm_trigger "$1"
                                  break 1
                          fi
                          sleep 1
                  else
                          system_disarmed
                          break 1
                  fi
          done
}

function Red_on {
        echo "0" > /sys/class/gpio/gpio"$Red_led"/value
        red=1
}
function Red_off {
        echo "1" > /sys/class/gpio/gpio"$Red_led"/value
        red=0
}
function Green_on {
        echo "0" > /sys/class/gpio/gpio"$Green_led"/value
}
function Green_on {
        echo "1" > /sys/class/gpio/gpio"$Green_led"/value
}

arm=$ArmingTime
dis=$DisarmTime
for i in "${SensorPins[@]}"; do
          echo "Activating Pin $i"
          raspi-gpio set "$i" ip pu
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
          echo "in" > /sys/class/gpio/gpio"$i"/direction
done

echo "Activating Pin Red LED"
echo "$Red_led" > /sys/class/gpio/export
sleep 1.0
echo "out" > /sys/class/gpio/gpio"$Red_led"/direction
echo "1" > /sys/class/gpio/gpio"$Red_led"/value
        
echo "Activating Pin Green LED"
echo "$Green_led" > /sys/class/gpio/export
sleep 1.0
echo "out" > /sys/class/gpio/gpio"$Green_led"/direction
echo "1" > /sys/class/gpio/gpio"$Green_led"/value


while :
do
           if ls armed* > /dev/null 2>&1; then
               Green_off
               Red_on
               system_armed
           else
                Red_off
                Green_on
                system_disarmed
           fi
       sleep 0.5
done

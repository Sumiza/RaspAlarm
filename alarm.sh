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
PhoneNrsAlarmCall=($Phone_Numbers_Call)
TwilioSID=$Twilio_SID
TwilioAT=$Twilio_AH
TwilioDiD=$Twilio_DID
Twilio_xml=$Twilio_XML
Led_Red_Green=($LED_Red_Green)
Beeppin=$Beep_Noise_Pin
Sirenpin=$Siren_Pin
Logfile=$Log_File
Loglength=$Log_Length_Lines


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

function make_call {
        curl -X POST \
        --data-urlencode "Url=""$Twilio_xml""" \
        --data-urlencode "To=$1" \
        --data-urlencode "From=$TwilioDiD" \
        "https://api.twilio.com/2010-04-01/Accounts/""$TwilioSID""/Calls" \
        -u "$TwilioSID":"$TwilioAT"
}

function system_armed_once {
       echo "ARMED NOW"
       echo "$(date)" "$(find -- Armed* | head -n1)" >> "$Logfile"
       for i in "${PhoneNrsArm[@]}"; do
                 echo "SMS Sent to Armed $i $(find -- Armed* | head -n1)"
                 send_sms "$i" "Alarm Armed: $(find -- Armed* | head -n1)"
       done
        while [ "$(wc -l < "$Logfile" )" -gt "$Loglength" ]; do
                sed -i 1d "$Logfile"
        done
       # do stuff here when alarm activates, runs once.
}

function system_disarmed_once {
       echo "Disarmed now"
       echo "$(date)" "$(find -- Disarmed* | head -n1)" >> "$Logfile"
       for i in "${PhoneNrsDis[@]}"; do
                 echo "SMS sent to Disarmed $i $(find -- Disarmed* | head -n1)"
                 send_sms "$i" "Alarm Disarmed: $(find -- Disarmed* | head -n1)"
       done
        # do stuff here when alarm deactivates, runs once.
}

function alarm_trigger {
          echo "TRIGGER ALARM !!!!"
          echo "$(date)" "ALARM TRIGGERED on pin $1" >> "$Logfile"
          Red_on
          Beep_on
          Siren_on
          sendcount=$TimeBetweenMessage
          while ls Armed* > /dev/null 2>&1; do
                  echo "$sendcount"
                  if [ "$sendcount" -eq "$TimeBetweenMessage" ] || [ "$sendcount" -eq 0 ]; then
                        echo "sending message and calling"
                        for i in "${PhoneNrsAlarm[@]}"; do
                                echo "SMS sent to ALARM $i"
                                send_sms "$i" "Alarm Triggered on Pin $1"
                        done
                        for i in "${PhoneNrsAlarmCall[@]}"; do
                                echo "Calling ALARM $i"
                                make_call "$i"
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
                  if ls Armed* > /dev/null 2>&1; then
                       echo "$arm"
                       if [ "$red" = "1" ]; then
                                Red_off
                                Beep_off
                       else
                                Red_on
                                Beep_on
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
          if ls Armed* > /dev/null 2>&1; then
                  rm Armed*
          fi
          arm=$ArmingTime
          dis=$DisarmTime
       fi
       echo "Not Armed"
}

function alarm_countdown {
          echo "alarm countdown..."
          while [ "$dis" -ge 0 ]; do
                  if ls Armed* > /dev/null 2>&1; then
                           if [ "$red" = "1" ]; then
                                    Red_off
                                    Beep_off
                           else
                                    Red_on
                                    Beep_on
                           fi
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
        echo "0" > /sys/class/gpio/gpio"${Led_Red_Green[0]}"/value
        red=1
}
function Red_off {
        echo "1" > /sys/class/gpio/gpio"${Led_Red_Green[0]}"/value
        red=0
}
function Green_on {
        echo "0" > /sys/class/gpio/gpio"${Led_Red_Green[1]}"/value
        green=1
}
function Green_off {
        echo "1" > /sys/class/gpio/gpio"${Led_Red_Green[1]}"/value
        green=0
}
function Beep_on {
        echo "1" > /sys/class/gpio/gpio"$Beeppin"/value
        beep=1
}
function Beep_off {
        echo "0" > /sys/class/gpio/gpio"$Beeppin"/value
        beep=0
}
function Siren_on {
        echo "1" > /sys/class/gpio/gpio"$Sirenpin"/value
        siren=1
}
function Siren_off {
        echo "0" > /sys/class/gpio/gpio"$Sirenpin"/value
        siren=0
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

for i in "${Led_Red_Green[@]}"; do
        echo "Activating LED Pin $i"
        echo "$i" > /sys/class/gpio/export
        sleep 1.0
        echo "out" > /sys/class/gpio/gpio"$i"/direction
        echo "1" > /sys/class/gpio/gpio"$i"/value
done
echo "Activating Beep Pin"
echo "$Beeppin" > /sys/class/gpio/export
sleep 1.0
echo "out" > /sys/class/gpio/gpio"$Beeppin"/direction
echo "0" > /sys/class/gpio/gpio"$Beeppin"/value

echo "Activating Siren Pin"
echo "$Sirenpin" > /sys/class/gpio/export
sleep 1.0
echo "out" > /sys/class/gpio/gpio"$Sirenpin"/direction
echo "0" > /sys/class/gpio/gpio"$Sirenpin"/value


while :
do
           if ls Armed* > /dev/null 2>&1; then
                if [ "$red" != "1" ] || [ "$green" != "0" ]; then
                        Green_off
                        Red_on
                fi
                system_armed
           else
                if [ "$red" != "0" ] || [ "$green" != "1" ]; then
                        Red_off
                        Green_on
                fi
                system_disarmed
           fi
           if [ "$beep" = "1" ] || [ "$siren" = "1" ]; then
                Beep_off
                Siren_off
                fi
       sleep 0.5
done

#!/bin/bash
rm alarm.sh
rm keypad.sh
rm smscontrol.sh
rm update.sh
wget https://raw.githubusercontent.com/Sumiza/raspalarm/main/keypad.sh
wget https://raw.githubusercontent.com/Sumiza/raspalarm/main/alarm.sh
wget https://raw.githubusercontent.com/Sumiza/raspalarm/main/smscontrol.sh
wget https://raw.githubusercontent.com/Sumiza/RaspAlarm/main/startup.sh
chmod +x alarm.sh
chmod +x keypad.sh
chmod +x smscontrol.sh
chmod +x startup.sh
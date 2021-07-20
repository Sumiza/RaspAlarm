#!/bin/bash
rm alarm.sh
rm keypad.sh
rm smscontrol.sh
wget https://raw.githubusercontent.com/Sumiza/raspalarm/main/keypad.sh
wget https://raw.githubusercontent.com/Sumiza/raspalarm/main/alarm.sh
wget https://raw.githubusercontent.com/Sumiza/raspalarm/main/smscontrol.sh
chmod +x alarm.sh
chmod +x keypad.sh
chmod +x smscontrol.sh

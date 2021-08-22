#!/bin/bash
sleep 5
./keypad.sh &
sleep 10
./alarm.sh &
sleep 10
./smscontrol.sh &
sleep 5
./doording.sh &

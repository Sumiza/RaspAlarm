#!/bin/bash

source alarm.conf
passlist=($KeyPad_Passwords)
passusers=($KeyPad_Users)
inkeypins=($KeyPad_InPins)
outkeypins=($KeyPad_OutPins)
inpad0=("1" "2" "3" "A")
inpad1=("4" "5" "6" "B")
inpad2=("7" "8" "9" "C")
inpad3=("*" "0" "#" "D")
passhold=""

for i in "${inkeypins[@]}"; do
          echo "Activating Pin $i"
          raspi-gpio set "$i" ip pd
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
          echo "in" > /sys/class/gpio/gpio"$i"/direction
done

for i in "${outkeypins[@]}"; do
          echo "Activating Pin $i"
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
          echo "out" > /sys/class/gpio/gpio"$i"/direction
          echo "0" > /sys/class/gpio/gpio"$i"/value
done

function passcheck {
        if [ "$1" = "#" ]; then
                passhold=""
                echo "clear"
        else
                passhold="$passhold$1"
                echo "$passhold"
                passname=0
                for pass in "${passlist[@]}"; do
                        if [ "$pass" = "$passhold" ]; then
                                if ls armed* > /dev/null 2>&1; then
                                        rm disarmed*
                                        touch disarmed_"${passusers[$passname]}"
                                        rm armed*
                                        echo "keypad disarmed by ${passusers[$passname]}"
                                else
                                        touch armed_"${passusers[$passname]}"
                                        echo "keypad armed by ${passusers[$passname]}"
                                fi
                                passhold=""
                        fi
                        ((passname=passname+1))
                done
        fi
}

while :
do
        c=0
        for o in "${outkeypins[@]}"; do
                echo "1" > /sys/class/gpio/gpio"$o"/value
                for i in "${inkeypins[@]}"; do
                        keydown=$(cat /sys/class/gpio/gpio"$i"/value)
                        if [ "$keydown" = "1" ]; then
                                if [ "$i" = "${inkeypins[0]}" ]; then
                                        passcheck "${inpad0[c]}"
                                elif  [ "$i" = "${inkeypins[1]}" ]; then
                                       passcheck "${inpad1[c]}"
                                elif  [ "$i" = "${inkeypins[2]}" ]; then
                                        passcheck "${inpad2[c]}"
                                elif  [ "$i" = "${inkeypins[3]}" ]; then
                                        passcheck "${inpad3[c]}"
                                fi
                                sleep 0.3
                        fi
                done
                echo "0" > /sys/class/gpio/gpio"$o"/value
                ((c=c+1))
        done
done

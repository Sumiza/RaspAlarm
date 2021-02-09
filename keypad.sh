#!/bin/bash


inkeypins=(6 13 19 26)
outkeypins=(12 16 20 21)
inpad0=(1 2 3 A)
inpad1=(4 5 6 B)
inpad2=(7 8 9 C)
inpad3=("*" "0" "#" "D")


for i in "${inkeypins[@]}"; do
          echo "Activating Pin $i"
          raspi-gpio set "$i" ip pd
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
          echo "in" > /sys/class/gpio/gpio"$i"/direction
done

for i in "${outkeypins[@]}"; do
          echo "Activating Pin $i"
        #  raspi-gpio set "$i" op dl
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
          echo "out" > /sys/class/gpio/gpio"$i"/direction
          echo "0" > /sys/class/gpio/gpio"$i"/value
done


while :
do
        c=0
        for o in "${outkeypins[@]}"; do
                echo "1" > /sys/class/gpio/gpio"$o"/value
                for i in "${inkeypins[@]}"; do
                        keydown=$(cat /sys/class/gpio/gpio"$i"/value)
                        if [ "$keydown" = "1" ]; then
                                echo "$o - $i"
                                echo "${inpad0[$o]}"
                                if [ "$i" = "${inkeypins[0]}" ]; then
                                        echo "${inpad0[c]}"
                                elif  [ "$i" = "${inkeypins[1]}" ]; then
                                       echo "${inpad1[c]}" 
                                elif  [ "$i" = "${inkeypins[2]}" ]; then
                                        echo "${inpad2[c]}"
                                elif  [ "$i" = "${inkeypins[3]}" ]; then
                                        echo "${inpad3[c]}"
                                fi
                        fi
                done
                echo "0" > /sys/class/gpio/gpio"$o"/value
        done
        ((c=c+1))
done

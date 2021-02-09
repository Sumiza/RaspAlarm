#!/bin/bash


inkeypins=(6 13 19 26)
outkeypins=(12 16 20 21)

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
        for o in "${outkeypins[@]}"; do
        
                echo "1" > /sys/class/gpio/gpio"$o"/value
                for i in "${inkeypins[@]}"; do
                        keydown=$(cat /sys/class/gpio/gpio"$i"/value)
                        if [ "$keydown" = "1" ]; then
                                echo "$o - $i"
                        fi
                done
                echo "0" > /sys/class/gpio/gpio"$o"/value
        done
done

#!/bin/bash


keypins=(6 13 19 26 12 16 20 21)

for i in "${keypins[@]}"; do
          echo "Activating Pin $i"
          raspi-gpio set "$i" ip pu
          echo "$i" > /sys/class/gpio/export
          sleep 1.0
          echo "in" > /sys/class/gpio/gpio"$i"/direction
done

while :
do
        for i in "${keypins[@]}"; do
                echo "$(cat /sys/class/gpio/gpio"$i"/value)"
        done
        sleep 5
done

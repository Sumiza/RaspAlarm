#!/bin/bash


keypins=(06 013 019 026 012 016 020 021)

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

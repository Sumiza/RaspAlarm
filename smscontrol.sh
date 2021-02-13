#!/bin/bash

source alarm.conf
TwilioSID=$Twilio_SID
TwilioAT=$Twilio_AH
TwilioDiD=$Twilio_DID

function get_messages {
	curl -X GET https://api.twilio.com/2010-04-01/Accounts/"$TwilioSID"/Messages.json?PageSize=1 \
                        -u "$TwilioSID":"$TwilioAT"
}

function send_message {
        curl -X POST https://api.twilio.com/2010-04-01/Accounts/"$TwilioSID"/Messages.json \
        --data-urlencode "Body=$2" \
        --data-urlencode "From=$TwilioDiD" \
        --data-urlencode "To=$1" \
        -u "$TwilioSID":"$TwilioAT"
}

while :
do
        apianswer=$(get_messages)
        contact=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d'"' -f 16)
        message=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d'"' -f 4)
        id=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d'"' -f 28)
        direction=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d'"' -f 12)
        message=${message,,}
        
        echo "------------"
        echo "$apianswer"
        echo "------------"
        echo "$contact"
        echo "------------"
        echo "$message"
        echo "------------"
        echo "$id"
        echo "------------"
        echo "$direction"
        echo "------------"
        
		if [ "$contact" != "" ] && [ "$message" != "" ] && [ "$id" != "" ] &&  [ "$direction" = "inbound" ]; then
			if ls armed* > /dev/null 2>&1; then
			        if [ "$message" = "status" ]; then
			                send_message "$contact" "Status_Armed"
			                echo "status armed"
				
				elif [ "$message" = "arm" ]; then
				        send_message "$contact" "Already_armed"
				        
				elif [ "$message" = "disarm" ]; then
				        rm disarmed*
				        touch disarmed_"$contact"
				        rm armed*
				fi
			else
			        if [ "$message" = "status" ]; then
			                send_message "$contact" "Status_Disarmed"
			                echo "status disarmed"
				
				elif [ "$message" = "arm" ]; then
			               touch armed_"$contact"
			               
				elif [ "$message" = "disarm" ]; then
				        send_message "$contact" "Already_Disarmed"
				fi
			fi
		fi
        		if [ "$id" != "" ]; then
                                curl -X DELETE https://api.twilio.com"$id" \
                                        -u "$TwilioSID":"$TwilioAT"
                        fi
        sleep 15
done

#!/bin/bash

source alarm.conf
TwilioSID=$Twilio_SID
TwilioAT=$Twilio_AH
TwilioDiD=$Twilio_DID
controlnumbers=($Phone_Numbers_Control)
controlusers=($Phone_Numbers_Users)
smspass=($Phone_Numbers_Passwords)

function get_messages {
	curl -G -X GET \
	--data-urlencode "To=$TwilioDiD" \
	--data-urlencode "PageSize=1" \
        -u "$TwilioSID":"$TwilioAT" \
	https://api.twilio.com/2010-04-01/Accounts/"$TwilioSID"/Messages.json
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
        message=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d':' -f 2 |  cut -d'"' -f 2 | cut -d ' ' -f 1)
        pass=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d':' -f 2 |  cut -d'"' -f 2 | cut -d ' ' -f 2)
        direction=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d':' -f 4 | cut -d'"' -f 2)
        contact=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d':' -f 5 | cut -d'"' -f 2)
        id=$(echo "$apianswer" | cut -d'{' -f 3 | cut -d':' -f 11 | cut -d'"' -f 2)
        message=${message,,}

        echo "------------"
        echo "$apianswer"
        echo "------------"
        echo "$message"
        echo "------------"
	echo "$direction"
        echo "------------"
        echo "$contact"
        echo "------------"
        echo "$id" 
        echo "------------"
        echo "$pass"
	echo "------------"
        
		if [ "$contact" != "" ] && [ "$message" != "" ] && [ "$id" != "" ] &&  [ "$direction" = "inbound" ]; then
			c=0
			for i in "${controlnumbers[@]}"; do
			        if [ "$i" = "$contact" ]; then
		                        if [ "${smspass[c]}" = "$pass" ]; then
                        			if ls Armed* > /dev/null 2>&1; then
                        			        if [ "$message" = "status" ]; then
                        			                send_message "$contact" "Armed Status: $(find -- Armed* | head -n1)"
                        			                echo "status Armed"
                        				
                        				elif [ "$message" = "arm" ]; then
                        				        send_message "$contact" "Already Armed: $(find -- Armed* | head -n1)"
                        				        
                        				elif [ "$message" = "disarm" ]; then
                        				        rm Disarmed*
                        				        touch "Disarmed by SMS by ""${controlusers[c]}"" at ""$(date)"""
                        				        rm Armed*
                        				fi
                        			else
                        			        if [ "$message" = "status" ]; then
                        			                send_message "$contact" "Disarmed Status: $(find -- Disarmed* | head -n1)"
                        			                echo "status Disarmed"
                        				
                        				elif [ "$message" = "arm" ]; then
                        			                touch "Armed by SMS by ""${controlusers[c]}"" at ""$(date)"""
                        			               
                        				elif [ "$message" = "disarm" ]; then
                        				        send_message "$contact" "Already Disarmed: $(find -- Disarmed* | head -n1)"
                        				fi
                        			fi
                        		fi
                		fi
                		((c=c+1))
        		done
		fi
        	if [ "$id" != "" ]; then
                        curl -X DELETE https://api.twilio.com"$id" \
                        -u "$TwilioSID":"$TwilioAT"
                fi
        sleep 10
done

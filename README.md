# RaspAlarm

Alarm system made for the raspberry pi (should work on any version)

Written fully in bash so that it is easily modifiable no library or dependencies, other than raspi-gpio which can be avoided if needed by installing physical resistors.

The main script can be used with both or either of the other ones, smscontrol.sh if you want to want to control it via sms messages and keypad.sh if you want to use a keypad.

Alarm.sh – This is the main script, all settings / info is in the alarm.conf file.

Smscontrol.sh – Requires a twilio account to use, an account can be made for free to test, after that the cost is about 1$ a month per number with however much you use, expect about 2-3$ a month if you just arm and disarm it once a day.
Access – Set the sms control phone numbers, only people that send messages from these numbers will be read by the script, user names can be attached to each phone number and passwords. Passwords aren’t necessary but are suggested as phone numbers can be spoofed. Passwords can be any length and are used after the command “arm 1234” will only work in that format.
Commands - Arm, Disarm, Status.

Keypad.sh – The keypad this is set up for is a 4x4 matrix keypad, 4 in 4 out pins which are set in the alarm.conf file (can use whichever pins you want). The passwords can be made up of any character and any length other than # as that clears the current password.  It has a built in timeout if no button is pushed for 10 seconds it will clear the password itself.

-----------------------------------------------------------------------


FAQ:

Why not use python, existing libraries would make this faster and easier?

Wanted to write something from scratch not using premade libraries or having any dependencies (yes using raspi-gpio to set pull up resistor, as only other way would be via physical resistors)

The sms and call, why twilio?

Planned on using Voipms but their api doesn't allow making calls. Twilio on the other hand isn't great with reading incoming messages right from bash, so might change it out to another provider at some point.

Why sms and call, not push or some app?

Just wanted it to work with any phone, adding push notification for *insert app here* wouldn't be hard to do but there are lots of different ones and I don't really use them much.

Should I use this for…?

No, I just made this as a little project for myself and because I got upset at my current security system provider. If you want to use it I would suggest you fork it, while I tried to make it as modifiable as possible via the conf file, could change things that might break current versions.

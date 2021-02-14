# RaspAlarm

sms/keypad/door/motion sensor
WIP

A security system made out of a raspberry pi, written fully in bash.

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

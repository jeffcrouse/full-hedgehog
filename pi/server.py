#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time, threading, OSC
from ofMap import ofMap

receive_address = 'hedgehog.local', 7000
s = OSC.OSCServer(receive_address)
s.addDefaultHandlers()

# Initialise the PWM devices
pwm = []
pwm.append( PWM(0x40, debug=False) )
pwm.append( PWM(0x41, debug=False) )
pwm.append( PWM(0x42, debug=False) )

for i in range(0, 3):
	pwm[i].setPWMFreq(60)     # Set frequency to 60 Hz


servoMin = 380  # Min pulse length out of 4096
servoMax = 520  # Max pulse length out of 4096
def pwm_handler(addr, tags, stuff, source):
	i = stuff[0] # channel from OSC
	v = stuff[1] # value for channel

	p = int( i / 16.0 )
	channel = int(i % 16)
	value = ofMap(v, 0.0, 1.0, servoMin, servoMax, True)
	pwm[p].setPWM(channel, 0, int(value))


s.addMsgHandler("/pwm", pwm_handler)


# just checking which handlers we have added
print "Registered Callback-functions are :"
for addr in s.getOSCAddressSpace():
	print addr


# Start OSCServer
print "\nStarting OSCServer. Use ctrl-C to quit."
st = threading.Thread( target = s.serve_forever )
st.start()
 
# Loop while threads are running.
try :
	while 1 :

		time.sleep(10)
 
except KeyboardInterrupt :
	print "\nClosing OSCServer."
	s.close()
	print "Waiting for Server-thread to finish"
	st.join()
	print "Done"



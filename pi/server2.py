#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import math, OSC
from ofMap import ofMap
from threading import Thread
from time import sleep

receive_address = 'hedgehog.local', 7000
s = OSC.OSCServer(receive_address)
s.addDefaultHandlers()

TWO_PI = math.pi * 2
servoMin = 380  # Min pulse length out of 4096
servoMax = 500  # Max pulse length out of 4096
servoRange = servoMax - servoMin

pwm = []
pwm.append( PWM(0x40, debug=False) )
pwm.append( PWM(0x41, debug=False) )
pwm.append( PWM(0x42, debug=False) )

level = 0.001

offsets = {
	0: 0.3, 	1: 0.06, 	2: 0.22, 	3: 0.1, 
	4: 0.05, 	5: 0.05, 	6: 0.17, 	7: 0.15, 
	8: 0.05, 	9: 0.27, 	10: 0, 		11: 0.27, 
	12: 0.24, 	13: 0.15, 	14: 0.11, 	15: 0.06,
	16: 0.12, 	17: 0.09, 	18: 0, 		19: 0.04,
	20: 0.2, 	21: 0.05, 	22: 0.01, 	23: 0.1, 
	24: 0.1, 	25: -0.05, 	26: 0.06, 	27: 0.12, 	
	28: 0.07, 	29: 0.1,	30: 0, 		31: 0.1, 
	32: 0.03, 	33: 0.02, 	34: 0, 		35: -0.15, 
	36: 0, 		37: -0.08, 	38: 0, 		39: 0, 
	40: 0.1, 	41: -0.05, 	42: 0}

theta = []
for i in range(0, 43):
	theta.append ( (i/43.0) * TWO_PI )

for i in range(0, 3):
	pwm[i].setPWMFreq(60)                        # Set frequency to 60 Hz


def level_handler(addr, tags, stuff, source):
	global level
	level = stuff[0]
	if(level==0) :
		level = 0.001


s.addMsgHandler("/level", level_handler)


# just checking which handlers we have added
print "Registered Callback-functions are :"
for addr in s.getOSCAddressSpace():
	print addr


# Start OSCServer
print "\nStarting OSCServer. Use ctrl-C to quit."
st = Thread( target = s.serve_forever )
st.start()


# Loop while threads are running.
try :
	while (True) :
		frameMax = ofMap(level, 0, 1, servoMin, servoMax, True)
		for i in range(0, 43):
			p = int( i / 16.0 )
			channel = int(i % 16)

			value =  ofMap(math.cos(theta[i]), -1, 1, servoMin, frameMax, True)
			
			if i in offsets:
				offset = servoRange * offsets[i]
				value += offset

			theta[i] += 0.2
			#print "hat %d channel %d value = %s" % (p, channel, value)
			pwm[p].setPWM(channel, 0, int(value))
		sleep(1/60.0)
 
except KeyboardInterrupt :
	print "\nClosing OSCServer."
	s.close()
	print "Waiting for Server-thread to finish"
	st.join()
	print "Done"


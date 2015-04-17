#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time, math
from ofMap import ofMap

TWO_PI = math.pi * 2
servoMin = 380  # Min pulse length out of 4096
servoMax = 520  # Max pulse length out of 4096


pwm = []
pwm.append( PWM(0x40, debug=False) )
pwm.append( PWM(0x41, debug=False) )
pwm.append( PWM(0x42, debug=False) )

theta = []
for i in range(0, 43):
	theta.append ( (i/43.0) * TWO_PI )

for i in range(0, 3):
	pwm[i].setPWMFreq(60)                        # Set frequency to 60 Hz


while(True):
	for i in range(0, 43):
		p = int( i / 16.0 )
		channel = int(i % 16)
		value =  ofMap(math.cos(theta[i]), -1, 1, servoMin, servoMax, True)
		theta[i] += 0.5
		#print "hat %d channel %d value = %s" % (p, channel, value)
		pwm[p].setPWM(channel, 0, int(value))


		


# while(True):
# 	for i in range(0,3):
# 		for channel in range(0, 16):
# 			for pulse in range(servoMin, servoMax, 2):
# 				pwm[i].setPWM(channel, 0, pulse)
# 			for pulse in reversed(range(servoMin, servoMax, 2)):
# 				pwm[i].setPWM(channel, 0, pulse)


#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time, math, sys

servoMin = 380  # Min pulse length out of 4096
servoMax = 500  # Max pulse length out of 4096
servoRange = servoMax - servoMin
servoMid = servoMin + (servoRange / 2.0)

pwm = []
pwm.append( PWM(0x40, debug=False) )
pwm.append( PWM(0x41, debug=False) )
pwm.append( PWM(0x42, debug=False) )


offsets = {
	0: 0.3, 1: 0.06, 2: 0.22, 3: 0.1, 
	4: 0.05, 5: 0.05, 6: 0.17, 7: 0.15, 
	8: 0.05, 9: 0.27, 10: 0, 11: 0.27, 
	12: 0.24, 13: 0.15, 14: 0.11, 15: 0.06,
	16: 0.12, 17: 0.09, 18: 0, 19: 0.04,
	20: 0.2, 21: 0.05, 22: 0.01, 23: 0.1, 24: 0.1,
	25: -0.05, 26: 0.06, 27: 0.12, 28: 0.07, 29: 0.1,
	30: 0, 31: 0.1, 32: 0.03, 33: 0.02, 34: 0, 
	35: -0.15, 36: 0, 37: -0.08, 38: 0, 39: 0, 40: 0.1, 
	41: -0.05, 42: 0}

for i in range(0, 3):
	pwm[i].setPWMFreq(60)                        # Set frequency to 60 Hz

def main(argv):
	target = servoMin
	if(len(sys.argv)>1 and sys.argv[1]=="max"):
		target = servoMax
	if(len(sys.argv)>1 and sys.argv[1]=="mid"):
		target = servoMid

	for i in range(0, 43):
		p = int( i / 16.0 )
		channel = int(i % 16)
		value = target
		if i in offsets:
			offset = servoRange * offsets[i]
			value += offset
			print "offset %d by %f" % (channel, offset)

		pwm[p].setPWM(channel, 0, int(value))

if __name__ == "__main__":
	main(sys.argv[1:])
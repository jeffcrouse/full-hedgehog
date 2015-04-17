#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time, math, sys

servoMin = 380  # Min pulse length out of 4096
servoMax = 520  # Max pulse length out of 4096
servoRange = servoMax - servoMin
servoMid = servoMin + (servoRange / 2.0)

pwm = []
pwm.append( PWM(0x40, debug=False) )
pwm.append( PWM(0x41, debug=False) )
pwm.append( PWM(0x42, debug=False) )

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
		pwm[p].setPWM(channel, 0, int(target))

if __name__ == "__main__":
	main(sys.argv[1:])
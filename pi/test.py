#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time

# ===========================================================================
# Example Code
# ===========================================================================

# Initialise the PWM device using the default address
#pwm = PWM(0x40)
# Note if you'd like more debug output you can instead run:
pwm = PWM(0x40, debug=True)

servoMin = 380  # Min pulse length out of 4096
servoMax = 520  # Max pulse length out of 4096

channels = [0, 1, 2, 3, 4, 5, 6, 7, 12]
offsets = [0, 0, 0, 0, 0, 40, 0, -20, 0]

def setServoPulse(channel, pulse):
	pulseLength = 1000000                   # 1,000,000 us per second
	pulseLength /= 60                       # 60 Hz
	print "%d us per period" % pulseLength
	pulseLength /= 4096                     # 12 bits of resolution
	print "%d us per bit" % pulseLength
	pulse *= 1000
	pulse /= pulseLength
	pwm.setPWM(channel, 0, pulse)

pwm.setPWMFreq(60)                        # Set frequency to 60 Hz

# for i in range(0, 9):
# 	channel = channels[i]
# 	pwm.setPWM(channel, 0, servoMin)

while(True):
	for i in range(1, 2):
		channel = channels[i]
		for i in range(servoMin, servoMax, 2):
			pwm.setPWM(channel, 0, i)
		for i in reversed(range(servoMin, servoMax, 2)):
			pwm.setPWM(channel, 0, i)


# while (True):
# 	for i in range(0, 9):
# 		channel = channels[i]

# 		print "%d servoMin" % channel
# 		# Change speed of continuous servo on channel O
# 		pwm.setPWM(channel, 0, servoMin + offsets[i])
# 		time.sleep(0.2)
# 		print "%d servoMax" % channel
# 		pwm.setPWM(channel, 0, servoMax + offsets[i])
# 		time.sleep(0.1)




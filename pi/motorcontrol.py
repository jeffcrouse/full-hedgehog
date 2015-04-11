#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time, threading, OSC

receive_address = '127.0.0.1', 7000
s = OSC.OSCServer(receive_address)
s.addDefaultHandlers()

# Initialise the PWM device using the default address
pwm = PWM(0x40, debug=True)

servoMin = 150  # Min pulse length out of 4096
servoMax = 600  # Max pulse length out of 4096

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
# while (True):
# 	for x in range(0, 9):
# 		print "%d servoMin" % x
# 		# Change speed of continuous servo on channel O
# 		pwm.setPWM(x, 0, servoMin)
# 		time.sleep(0.1)
# 		print "%d servoMax" % x
# 		pwm.setPWM(x, 0, servoMax)
# 		time.sleep(0.1)


def pwm_handler(addr, tags, stuff, source):
	print "---"
	print "received new osc msg from %s" % OSC.getUrlStr(source)
	print "with addr : %s" % addr
	print "typetags %s" % tags
	print "data %s" % stuff
	print "---"


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
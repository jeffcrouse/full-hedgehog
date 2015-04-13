#!/usr/bin/python

from Adafruit_PWM_Servo_Driver import PWM
import time, threading, OSC

receive_address = 'hedgehog.local', 7000
s = OSC.OSCServer(receive_address)
s.addDefaultHandlers()

# Initialise the PWM device using the default address
pwm = PWM(0x40, debug=False)

servoMin = 380  # Min pulse length out of 4096
servoMax = 520  # Max pulse length out of 4096

channel_map = [0, 1, 2, 3, 4, 5, 6, 7, 12]
offset_map = [0, 0, 0, 0, 0, 40, 0, -15, 0]

def ofMap(value, inputMin, inputMax, outputMin, outputMax, clamp=False):
	if abs(inputMin - inputMax) < 1.0e-30:
		print("ofMap: avoiding possible divide by zero, check inputMin and inputMax")
		return outputMin
	else:
		outVal = float(float(value - inputMin) / float(inputMax - inputMin) * float(outputMax - outputMin) + outputMin)
		if clamp:
			if outputMax < outputMin:
				if outVal < outputMax: 		outVal = outputMax
				elif outVal > outputMin:  	outVal = outputMin
			else:
				if outVal > outputMax: 		outVal = outputMax
				elif outVal < outputMin: 	outVal = outputMin
		return outVal


pwm.setPWMFreq(60)                        # Set frequency to 60 Hz

def pwm_handler(addr, tags, stuff, source):
	i = stuff[0]
	channel = channel_map[i]
	value = ofMap(stuff[1], 0, 1, servoMin, servoMax, True) + offset_map[i]
	# print "---"
	# print "received new osc msg from %s" % OSC.getUrlStr(source)
	# print "with addr : %s" % addr
	# print "typetags %s" % tags
	# #print "data %s" % stuff
	# print "channel %s=%s" % (channel, value)
	# print "---"

	pwm.setPWM(channel, 0, int(value))


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



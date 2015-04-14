

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
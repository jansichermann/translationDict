#!/usr/bin/env python
import random
import string
import pprint
import json
import math

variants = 4
numStrings = 800
verbose = False

def generateRandomStringWithFormatters(numFormatters):
	"""generates a random string with the given number of formatters"""

	# numFormatters = random.choice(range(0,4))
	dataString = ""

	iterations = random.choice(range(4,10))
	position = 1
	d = 0
	while d<iterations:
		dataString += "".join(random.choice(string.ascii_letters + " " + ".") for i in range(random.choice(range(1, 7))))
		if (position <= numFormatters):
			dataString += " {#" + str(position) + "} "
			
			position += 1
		d += 1
	return (dataString, numFormatters)




def generateDict(string, numLevels):
	"""returns a dict of dicts"""

	if (numLevels < 1):
		return string
	numLevels -= 1
	returnDict = {}
	for d in range(variants):
		returnDict[str(d)] = generateDict(string, numLevels)
	
	return returnDict



def generateNestedArray(string, numLevels):
	"""returns a nested array"""

	if (numLevels < 1):
		return string
	numLevels -= 1
	returnDict = []
	for d in range(variants):
		returnDict.append(generateDict(string, numLevels))
	
	return returnDict


def generateArray(string, numLevels):
	"""returns a dict with a flat array of variants"""

	returnArray = []
	for d in range(int(math.pow(variants, numLevels))):
		returnArray.append(string)
	return returnArray




if __name__ == '__main__':
	dictData = {}
	arrayData = {}
	nestedArrayData = {}

	for n in range(numStrings):
		randomFormatter = random.choice(range(0,4))
		stringData = generateRandomStringWithFormatters(randomFormatter)
		dictData[stringData[0]] = generateDict(stringData[0], stringData[1])
		arrayData[stringData[0]] = generateArray(stringData[0], stringData[1])
		nestedArrayData[stringData[0]] = generateNestedArray(stringData[0], stringData[1])

	if (verbose):
		pp = pprint.PrettyPrinter(indent=4)
		pp.pprint(dictData)

		pp.pprint(arrayData)

	fh = open('testDict.json', 'w')
	fh.write(json.dumps(dictData))
	fh.close()

	fh = open('testArray.json', 'w')
	fh.write(json.dumps(arrayData))
	fh.close()

	fh = open('testNestedArray.json', 'w')
	fh.write(json.dumps(nestedArrayData))
	fh.close()
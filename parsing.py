#!/usr/bin/env python
# parsing.py

import itertools
import re

def LocKeyWord():
	return "localizedString"

def LocStringIndex(line):
	"""returns the index of the function call start"""

	return line.find( LocKeyWord() )


def locStringType(line):
	"""returns the localizationType for line"""

	lsSubstring = line[LocStringIndex(line):]
	typeIndex = lsSubstring.find("_")
	typeEndIndex = lsSubstring.find(":")
	return lsSubstring[typeIndex:typeEndIndex]




def textStringForLine(line):
	"""returns the string to be translated"""
	lsSubstring = line[LocStringIndex(line):]
	textIndex = lsSubstring.find("@\"")+2
	textEndIndex = lsSubstring[textIndex:].find("\"")

	return lsSubstring[textIndex:textIndex+textEndIndex]




def descriptionForLine(line):
	"""returns the string description"""

	lsSubstring = line[LocStringIndex(line):]
	descriptionIndex = lsSubstring.find("description:@\"")+14
	descriptionEndIndex = lsSubstring[descriptionIndex:].find("\"")
	return lsSubstring[descriptionIndex:descriptionIndex+descriptionEndIndex]



def genderFormatsForLanguage(lang):
	if lang == "en":
		return ["0", "1"]


def genderPossibilityForLanguage(lang):
	if lang == "en":
		return [0,1]
	else:
		return [0,1,2]

def pluralizationPossibilityForLanguage(lang):
	if lang == "en":
		return [0,1]
	else:
		return [0,1,2]

def formatterArrayForLine(line):
	return re.findall("\{[\^#]\}", line)

def formatStringWithNumbers(line):
	m = formatterArrayForLine(line)
	d = 1
	textString = line
	for formatter in m:
		
		replaceFormatter =  "{" + formatter[1:2] + str(d) + "}"
		textString = textString.replace(formatter, replaceFormatter, 1)
		d += 1

	return textString

def genderDictForLine(line):
	genderDict = {}
	genderDict["0"] = line
	genderDict["1"] = line
	genderDict["2"] = line
	return genderDict

def blowoutString(line, lang):
	"""blows out a string according to pluralization and gender"""
	print line
	textString = textStringForLine(line)
	formatters = formatterArrayForLine(line)
	textString = formatStringWithNumbers(textString)

	blowoutDict = {}
	blowoutDict[textString] = {}

	d = len(formatters)
	i = 0
	while i < d:
		formatter = formatters[i]
		if formatter[1] == "^":
			print i
			print genderDictForLine(textString)
			print "\n"

		i += 1



	
	return line


	# formatters = formatText(textString, lang)
	# print formatters

	# printString = textString.replace("{#}", "%@")
	# printString = printString.replace("{^}", "%@")

	# listOfCombinations = []

	# for formatter in formatters:
	# 	listOfCombinations.append(formatter['possibilities'])

	# combinations = list(itertools.product(*listOfCombinations))

	# returnList = []

	
	# for combination in combinations:
	# 	i = 0
	# 	formatString = ""
	# 	helpString = ""
	# 	for item in combination:
	# 		if formatters[i]['key'] == " ^^__":
	# 			helpString += " || gender is"
	# 			if item == 0: 
	# 				helpString += " male"
	# 			elif item == 1:
	# 				helpString += " female"
	# 			else:
	# 				helpString += " neuter"
	# 		elif formatters[i]['key'] == " ##__":
	# 			helpString += " || pluralization is"
	# 			if item == 0:
	# 				helpString += " case 0"
	# 			elif item == 1:
	# 				helpString += " case 1"
	# 			elif item == 2:
	# 				helpString += " case 2"

	# 		formatString += formatters[i]['key'] + str(item)
	# 		i += 1
	# 	returnList.append( "\"" + printString + formatString + "\"" + " = " + "\"" + printString + "\"" + "; //" + helpString)
	# return returnList




					

if __name__ == '__main__':
	lang = "de"
	sourceFile = open("translationDictionary/MainViewController.m")
	sourceLines = sourceFile.readlines()
	writeString = ""

	for line in sourceLines:
		if LocKeyWord() in line:
			# writeString += "/* " + descriptionForLine(line) + " */" + "\n" 
			blowoutString(line, lang)
			# writeString += "\n".join(blowoutString(line, lang)) + "\n\n"
	# filePath = "translationTest/" + lang + ".lproj/Localizable.strings"
	# fileHandle = open(filePath, 'w')
	# fileHandle.write(writeString)
	# fileHandle.close()

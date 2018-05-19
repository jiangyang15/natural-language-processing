import re
from HTMLParser import HTMLParser
import NLPlib
import sys
import csv

tagger = NLPlib.NLPlib()

def twtt1( str ):
	''' HTML tag remover '''
	cleanr = re.compile('<.*?>')
  	cleantext = re.sub(cleanr, '', str)
  	return cleantext

def twtt2( str ):
	''' HTML character code to be replaced with ascii '''
	str = ''.join(i for i in str if ord(i)<128)
	h = HTMLParser()
	str = h.unescape(str)
	return str

def twtt3( str ):
	''' Remove all urls'''
	cleanHttp = re.compile('http\S+')
	cleanWWW = re.compile('www\S+')
	cleantext = re.sub(cleanHttp, '', str)
	cleantext = re.sub(cleanWWW, '', cleantext)
	return cleantext

def twtt4( str ):
	''' Remove all # and @'''
	cleantext = re.sub('@', '', str)
	cleantext = re.sub('#', '', cleantext)
	return cleantext

def twtt5( str ):
	''' Sentence splitter (Combine function on 5 and 6)
		
		Return: string
	'''
	sentenceEnders = re.compile(r'''(?:(?<=[.!?]) | (?<=[.!?]['"]))
													(?<!Mr\.)
													(?<!Mrs\.)
													(?<!Jr\.)
													(?<!Dr\.)
													(?<!Prof\.)
													(?<!Sr\.)
													(?<!St\.)
													(?<!Rd\.)
													(?<!\.\.\.)
													(?<!\!\!\!)
													(?<!\?\?\?)\s+''', re.IGNORECASE | re.VERBOSE)
	return sentenceEnders.split(str)

def twtt6( str ):
	''' Functionality for rule #6 has been included in twtt5
		
		Return: string itself
	'''
	return str

def twtt7( str ):
	''' Speprate tokens by spaces

		Return: string
	'''
	s = re.sub(r'([a-zA-Z0-9])([,.?!;:()])', r'\1 \2', str)
	s = re.sub(r'([,.?!;:()])([a-zA-Z0-9])', r'\1 \2', s)
	s = re.sub(r'([a-zA-Z])(\'s)', r'\1 \2', s)
	s = re.sub(r's\'', "s '", s)
	return s

def twtt8( str ):
	''' Tag token

		Return: string tagged with tag
	'''
	ret = ''
	str_list = str.split();
	tags = tagger.tag(str_list)
	for i in range(0, len(tags)):
		ret += str_list[i] + '/' + tags[i] + ' '

	return ret

def twtt9( list_obj ):
	''' Attach demarcation
	'''
	return list_obj[0]

def main():
	if len(sys.argv) != 4:
		print "There should be three arguments provided in this program. Aborting."
		sys.exit(1)

	filename = sys.argv[1]
	student = int(sys.argv[2])
	output_filename = sys.argv[3]
	X = student % 80

	# Use this for training data
	
	with open(filename, 'r') as csvfile:
		wholedata = csv.reader(csvfile)
		wholelist = list(wholedata)
		data = wholelist[X * 10000: (X + 1) * 10000]
		data.extend(wholelist[800000 + X * 10000: 810000 + X * 10000])
	'''
	# Use this for testing data
	with open(filename, 'r') as csvfile:
		wholedata = csv.reader(csvfile)
		wholelist = list(wholedata)
		data = wholelist
	'''
	output = open(output_filename, 'w')
	for row in data:
		polarity = twtt9(row)
		cleaned = twtt5(twtt4(twtt3(twtt2(twtt1(row[5])))))
		output.write('<A=' + polarity + '>\n')
		for line in cleaned:
			cleaned_line = twtt8(twtt7(twtt6((line))))
			output.write(cleaned_line + '\n')
		
if __name__== "__main__":
	main()









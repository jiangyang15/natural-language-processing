import re
import sys

def string_filtering( str, filter_list):
	str = str.lower()
	ret = 0
	for f in filter_list:
		ret += str.count(f)

	return ret

def feat1( str ):
	filter_list = ['i/', 'me/', 'my/', 'mine/', 'we/', 'us/', 'our/', 'ours/']
	return string_filtering(str, filter_list)

def feat2( str ):
	filter_list = ['you/', 'your/', 'yours/', 'u/', 'ur/', 'urs/']
	return string_filtering(str, filter_list)

def feat3( str ):
	filter_list = ['he/', 'him/', 'his/', 'she/', 'her/', 'hers/', 'it/', 'its/', 'they/', 'them/', 'their/', 'theirs/']
	return string_filtering(str, filter_list)

def feat4( str ):
	filter_list = ['/cc ']
	return string_filtering(str, filter_list)

def feat5( str ):
	filter_list = ['/vbd ']
	return string_filtering(str, filter_list)

def feat6( str ):
	filter_list = ['\'ll/', 'will/', 'gonna/', 'going to ']
	return string_filtering(str, filter_list)

def feat7( str ):
	filter_list = [',/']
	return string_filtering(str, filter_list)

def feat8( str ):
	filter_list = [':/', ';/']
	return string_filtering(str, filter_list)

def feat9( str ):
	filter_list = ['-/']
	return string_filtering(str, filter_list)

def feat10( str ):
	filter_list = ['(/', ')/']
	return string_filtering(str, filter_list)

def feat11( str ):
	filter_list = ['.../']
	return string_filtering(str, filter_list)

def feat12( str ):
	filter_list = ['/nn ', '/nns ']
	return string_filtering(str, filter_list)

def feat13( str ):
	filter_list = ['/nnp ', '/nnps ']
	return string_filtering(str, filter_list)

def feat14( str ):
	filter_list = ['/rb ', '/rbr ', '/rbs ']
	return string_filtering(str, filter_list)

def feat15( str ):
	filter_list = ['/wdt ', '/wp ', '/wrb ', '/wp$ ']
	return string_filtering(str, filter_list)

def feat16( str ):
	filter_list = [' smh/', ' fwb/', ' lmfao/', ' lmao/', ' lms/', ' tbh/', ' rofl/', ' wtf/', ' bff/', ' wyd/', \
		' lylc/', ' brb/', ' atm/', ' imao/', ' sml/', ' btw/', ' bw/', ' imho/', ' fyi/', ' ppl/', ' sob/', ' ttyl/', ' imo/', \
		' ltr/', ' thx/', ' kk/', ' omg/', ' ttys/', ' afn/', ' bbs/', ' cya/', ' ez/', ' f2f/', ' gtr/', ' ic/', ' jk/', ' k/', ' ly/', \
		' ya/', ' nm/', ' np/', ' plz/', ' ru/', ' so/', ' tc/', ' tmi/', ' ym/', ' ur/', ' u/', ' sol/']
	return string_filtering(str, filter_list)

def feat17( str ):
	ret = 0
	str_list = str.split()
	for s in str_list:
		start_idx = s.find('/')
		if (start_idx != -1):
			s = s[:start_idx]
			if s.isupper() and len(s) >= 2:
				ret += 1

	return ret

def feat18( str ):
	str_list = str.split('\n')
	total = 0.0
	number = 0.0
	for line in str_list:
		number += 1
		total += len(line.split())

	return total/number

def feat19( str ):
	p_list = ['./', ',/', ':/', '?/', '!/']
	str_list = str.split()
	total = 0.0
	number = 0.0
	for token in str_list:
		if any(ext in token for ext in p_list):
			continue
		start_idx = token.find('/')
		s = token[:start_idx]
		number += 1
		total += len(s)

	if number == 0:
		return 0
	return total/number

def feat20( str ):
	str_list = str.split('\n')
	return len(str_list) - 1

def main():
	if len(sys.argv) != 4 and len(sys.argv) != 3:
		print "This program only take two or three arguments. Aborting."
		sys.exit(1)

	input_file = sys.argv[1]
	output_file = sys.argv[2]
	cut_line = 10000

	if len(sys.argv) == 4:
		cut_line = int(sys.argv[3])

	with open(input_file, 'r') as twt_file:
		'''
		raw_data = twt_file.read()
		raw_data = '\n' + raw_data
		raw_data_list = raw_data.split('\n<A=0>\n')
		data_list = raw_data_list[1:len(raw_data_list)-1]
		a4_list = raw_data_list[-1]
		data_list.extend(a4_list.split('\n<A=4>\n'))
		cut_line = min(10000, cut_line)
		data = data_list[0:cut_line]
		data.extend(data_list[10000:10000+cut_line])'''
		raw_data_lines = twt_file.readlines()
		data_0 = []
		data_4 = []
		i = 0
		while i < len(raw_data_lines):
			start = i + 1
			if raw_data_lines[i] == '<A=4>\n':
				polarity = 4
			elif raw_data_lines[i] == '<A=0>\n':
				polarity = 0
			i += 1
			while i < len(raw_data_lines) and raw_data_lines[i] != '<A=4>\n' and raw_data_lines[i] != '<A=0>\n':
				i += 1
			end = i;
			s = ''.join(raw_data_lines[start:end])
			if polarity == 4:
				data_4.append(s)
			if polarity == 0:
				data_0.append(s)

		ot = open(output_file, 'w')
		ot.write('@RELATION tweet\n\n')
		ot.write('@ATTRIBUTE "First person pronouns"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Second person pronouns"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Third person pronouns"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Coordinating conjunctions"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Past-tense verbs"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Future-tense verbs"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Commas"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Colons and semi-colons"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Dashes"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Parentheses"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Ellipses"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Common nouns"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Proper nouns"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Adverbs"  NUMERIC\n')
		ot.write('@ATTRIBUTE "wh-words"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Modern slang acronyms"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Words all in upper case"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Average length of sentences"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Average length of tokens"  NUMERIC\n')
		ot.write('@ATTRIBUTE "Number of sentences"  NUMERIC\n')
		ot.write('@ATTRIBUTE "class"  {0, 4}\n\n')

		ot.write('@DATA\n')
		
		cut_line_0 = min(cut_line, len(data_0))
		cut_line_4 = min(cut_line, len(data_4))

		for i in range(0, cut_line_0):
			#ot.write(data_0[i])
			ot.write(str(feat1(data_0[i])) + ', ')
			ot.write(str(feat2(data_0[i])) + ', ')
			ot.write(str(feat3(data_0[i])) + ', ')
			ot.write(str(feat4(data_0[i])) + ', ')
			ot.write(str(feat5(data_0[i])) + ', ')
			ot.write(str(feat6(data_0[i])) + ', ')
			ot.write(str(feat7(data_0[i])) + ', ')
			ot.write(str(feat8(data_0[i])) + ', ')
			ot.write(str(feat9(data_0[i])) + ', ')
			ot.write(str(feat10(data_0[i])) + ', ')
			ot.write(str(feat11(data_0[i])) + ', ')
			ot.write(str(feat12(data_0[i])) + ', ')
			ot.write(str(feat13(data_0[i])) + ', ')
			ot.write(str(feat14(data_0[i])) + ', ')
			ot.write(str(feat15(data_0[i])) + ', ')
			ot.write(str(feat16(data_0[i])) + ', ')
			ot.write(str(feat17(data_0[i])) + ', ')
			ot.write(str(feat18(data_0[i])) + ', ')
			ot.write(str(feat19(data_0[i])) + ', ')
			ot.write(str(feat20(data_0[i])) + ', ')
			ot.write('0\n')

		for i in range(0, cut_line_4):
			#ot.write(data[i])
			ot.write(str(feat1(data_4[i])) + ', ')
			ot.write(str(feat2(data_4[i])) + ', ')
			ot.write(str(feat3(data_4[i])) + ', ')
			ot.write(str(feat4(data_4[i])) + ', ')
			ot.write(str(feat5(data_4[i])) + ', ')
			ot.write(str(feat6(data_4[i])) + ', ')
			ot.write(str(feat7(data_4[i])) + ', ')
			ot.write(str(feat8(data_4[i])) + ', ')
			ot.write(str(feat9(data_4[i])) + ', ')
			ot.write(str(feat10(data_4[i])) + ', ')
			ot.write(str(feat11(data_4[i])) + ', ')
			ot.write(str(feat12(data_4[i])) + ', ')
			ot.write(str(feat13(data_4[i])) + ', ')
			ot.write(str(feat14(data_4[i])) + ', ')
			ot.write(str(feat15(data_4[i])) + ', ')
			ot.write(str(feat16(data_4[i])) + ', ')
			ot.write(str(feat17(data_4[i])) + ', ')
			ot.write(str(feat18(data_4[i])) + ', ')
			ot.write(str(feat19(data_4[i])) + ', ')
			ot.write(str(feat20(data_4[i])) + ', ')
			ot.write('4\n')

if __name__== "__main__":
	main()



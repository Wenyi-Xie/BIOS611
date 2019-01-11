import re

# Parse pubmed search into separate files
# Make each file easier to parse in project 3.


def write_abstract_to_file(temp_lines, file_object):
	cat_line = ''
	passed_author_info = False
	abstract_present = False
	for tl in tmp_lines:
		# Read in paragraph
		if len(tl) > 1:
			cat_line += tl.strip() + ' '
		else:
		# Write output when reading in blank line
			if len(cat_line) > 1:

				if passed_author_info and not abstract_present:
					abstract_present = len(cat_line) > 10

				if cat_line.find('Author information') > -1:
					passed_author_info = True
					
				file_object.write(cat_line + '\n')
				cat_line = ''

	return abstract_present

# Main
with open('pubmed_result.txt', 'r', encoding='utf-8') as f:

	tmp_lines = []
	new = False
	for line in f:
		
		if re.search("^\d+\.\s", line) and not new:
			new = True
			tmp_lines = []
			match = re.search("^\d+\.\s", line).group(0)

			# Search for abstract number
			abs_cnt = re.compile("\.\s").sub("", match)
			keep_file = False

		tmp_lines.append(line)

		if line.find('PMID') > -1 and new:
			with open('abs_{}.txt'.format(abs_cnt), 'w', encoding='utf-8') as outfile:
				keep_file = write_abstract_to_file(tmp_lines, outfile)
			new = False



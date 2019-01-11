# This program reads in separate abstract TXT files
# Mainly focus on keyword processing
# Output separate structured file for further process in R


# System setting
import re
import pandas as pd
import nltk
from nltk.corpus import stopwords
import sys


# 1. Read in data
text = list(open(sys.argv[1]))

# 2. decide if author info and abstract both exist
passed_author_info = False
abstract_present = False
m = None
for tl in text:
    if m is None:
        m = re.search("^\d+\.\s", tl).group(0)
        m = re.sub("\.\s", "", m)

    if passed_author_info and not abstract_present:
        abstract_present = len(tl) > 10

    if tl.find('Author information') > -1:
        passed_author_info = True

# 3. if author info and abstract both exist, output the analysis result
if abstract_present and passed_author_info: 
    # 3.1 Deal with special abstract with irregular abstract structure
    core = [r.strip() for r in text]
    ind = [not bool(re.search('^Collaborators:', core)) for core in core]
    core = pd.Series(core)
    core = core[ind]

    # 3.2 Assign column names
    if pd.Series(core).size < 5:
        core = pd.Series(core)[:4]
        core.index = ['title',None,'institution','abstract']
    else:
        core = pd.Series(core)[:5]
        core.index = [None,'title',None,'institution','abstract']

    # 3.3 Separate raw text into title, institution and abstract
    title = core.loc['title']
    institution = core.loc['institution']
    abstract = core.loc['abstract']

    # 3.4 Dealing with Extract institutions
    ins_1 = re.split(r'[(]\d+[)]|[;]\s', institution)
    ins_1 = ins_1[1:]

    ins = pd.DataFrame(ins_1)
    ins.columns = ['Institution']

    # 3.5 Dealing with abstract
    stop = stopwords.words('english')

    # 3.5.1 Title words count 3 times
    abstract = abstract.lower() + ' ' + title.lower() + ' ' + title.lower() + ' ' + title.lower()

    # 3.5.2 Split paragraphe into words
    stract_1 = re.sub(r"[^a-zA-Z\s]", "", abstract).lower().split()

    # 3.5.3 Remove stop words
    keyword = [x for x in stract_1 if x not in stop]

    # 3.5.3 Let top 10 frequent words be keywords
    freq_1 = pd.Series(keyword).value_counts().rank(ascending=False, method = 'min')
    freq_1 = list(freq_1[freq_1<=10].index)

    # 3.5.4 Concatenate keywords by "|" 
    separator = "|"
    freq = separator.join(freq_1)

    # 3.6 Prepare for output
    ins['keyword'] = freq
    ins['id'] = str(m)
    ins = ins.fillna(method = "ffill")

    # 3.7 Write file
    ins.to_csv('prepR_{}.csv'.format(m), sep='\t', encoding='utf-8', header = False)

# 3. if either author info or abstract is absent, output blank file
else:
    with open('prepR_{}.csv'.format(m), 'w', encoding='utf-8') as f:
        pd.Series(0).to_csv('test.txt', sep='\t', encoding='utf-8', header = False)

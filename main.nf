#!/usr/bin/env nextflow


params.file_dir = 'pubmed_result.txt'
params.out_dir = 'data/'
params.out_dir_1 = 'prepR/'


file_channel = Channel.fromPath(params.file_dir)

process install {
	container 'wyxie/python'
	
	"""
	python -m nltk.downloader stopwords
	"""
}


process extraction {
    container 'wyxie/python'

    input:
    file f from file_channel

    output:
    file '*.txt' into out_txt

    """
    python $baseDir/split_abstracts.py
    """

}


process keyword {
	container 'wyxie/python'

	input:
	file f from out_txt.flatten()

	output:
	file '*.csv' into prepR

	"""
	python $baseDir/keywd_extract.py $f
	"""

}


process coll {
	container 'rocker/tidyverse:3.5'
	publishDir 'prepShiny', mode: 'copy'

	input:
	file f from prepR.collectFile( name:'fina_2.csv', newLine: true)

	output:
	file 'keyword_rank.csv' into prep_shiny

	"""
	Rscript $baseDir/freq_coll.R
	"""
}



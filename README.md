
## Description:
* **main.nf**: 
	pipeline
* **pubmed_result.txt**: 
	The raw file containing 462 abstracts searched from Pubmed
* **split_abstract.py**: 
	split pubmed_result.txt into separate abstract
* **keywd_extract.py**: 
	extract the keyword from each abstract
* **freq_coll.R**: 
	Extract and clean collaborator, generating keyword_rank.csv file for inputing Shiny
* **./python/dockerfile**: 
	Dockerfile for building image supporting keyword extraction
* **./r/dockerfile**: 
	Dockerfile for building image supporting shiny

* **app.R**: 
	Shiny app

## Procedure:

1. `nextflow main.nf`
2. `docker build -t shiny ./r`
3. `docker run -d -p 3838:3838 -p 8787:8787 -e PASSWORD=1234 -v $(pwd):/srv/shiny-server -v $(pwd):/var/log/shiny-server shiny`



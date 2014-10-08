all: slides.pdf
slides.tex: 
	wiki2beamer slides.wiki > out/slides.tex 
slides.pdf: slides.tex
	cd out && pdflatex slides.tex
amsterdam:
	wget 'http://latex.simon04.net/beamerthemeAmsterdam.sty' -O out/beamerthemeAmsterdam.sty


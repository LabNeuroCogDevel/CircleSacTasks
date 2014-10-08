all: slides.pdf
slides.tex: 
	wiki2beamer slides.wiki > out/slides.tex 
slides.pdf: slides.tex
	# run pdflatex twice to build navigation
	cd out && pdflatex slides.tex && pdflatex slides.tex
amsterdam:
	wget 'http://latex.simon04.net/beamerthemeAmsterdam.sty' -O out/beamerthemeAmsterdam.sty


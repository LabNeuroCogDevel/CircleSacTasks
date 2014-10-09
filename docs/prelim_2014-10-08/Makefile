SHELL=/bin/bash
all: theme pdf
tex: 
	wiki2beamer slides.wiki > out/slides.tex 

pdf: tex afni imgs shots 
	# run pdflatex twice to build navigation
	cd out && pdflatex slides.tex && pdflatex slides.tex

theme:
	#wget 'http://latex.simon04.net/beamerthemeAmsterdam.sty' -O out/beamerthemeAmsterdam.sty
	cd out && svn export https://github.com/fapper/beamertheme-bjeldbak/trunk/beamerthemebjeldbak.sty

imgs:
	# cannot figure out relative path, so wont bother :)
	#cp img/AttTypes.png img/FullAtt.png img/WMTypes.png img/FullWM.png out/
	cp img/*.png out/
	cp -r img/afni/ out/

afni:
	rsync -avhi skynet:/Volumes/Phillips/SzAttWM/pics/img/ img/afni/

shots:
	# use trial 9 for both WM and Att
	mkdir -p out/{Att,WM}
	cp ../../screenshots/Att/*09.png out/Att/
	cp ../../screenshots/WM/*09.png out/WM/

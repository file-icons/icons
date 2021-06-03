TTF = fonts/file-icons.ttf

all: svg font


# Tidy SVG source
svg:
	@./bin/clean-svg.pl svg/*.svg
.PHONY: svg


# Sort icons list
sort:
	head -n1 icons.tsv > icons.tsv~
	sort -k1,1 -dfik4,4 icons.tsv | grep -v ^\# >> icons.tsv~
	mv icons.tsv~ icons.tsv
.PHONY: sort


# Generate icon-font
font: $(TTF)

$(TTF):
	fontforge 2>&1 -quiet -lang=ff -script bin/build-font.ff \
	| sed '/^Copyright/, /^ Based/d'


# Extract a downloaded IcoMoon folder
unpack-icomoon:
	perldoc -lm Archive::Extract >/dev/null 2>&1 || cpan "$$_"
	test -f file-icons-*.zip && mv "$$_" file-icons.zip
	./bin/unpack.pl file-icons.zip
	./bin/compress.pl $(TTF)
	chmod 0644 icomoon.json dist/*

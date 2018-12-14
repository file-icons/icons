TTF = dist/file-icons.ttf

all: clean unpack charmap

# Install dependencies
install:
	cpan Archive::Extract
	npm --global install ppjson
.PHONY: install

# Nuke untracked files
clean:
	rm -rf tmp
	rm -f $(TTF)
.PHONY: clean

# Update character map
charmap:
	./bin/update-charmap.pl

# Extract a downloaded IcoMoon folder
unpack:
	./bin/unpack.pl file-icons.zip
	./bin/compress.pl $(TTF)

# Clean up SVG source
svg: $(wildcard svg/*.svg)
	@./bin/clean-svg.pl $^
.PHONY: svg

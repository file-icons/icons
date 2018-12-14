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
	rm -f $(TTF) *.html
.PHONY: clean

# Update character map
charmap:
	./bin/update-charmap.pl

# Generate an HTML preview of current character map
charmap-preview: charmap.html

charmap.html: charmap.md
	@ if command 2>&1 >/dev/null -v cmark-gfm; then GFM="cmark-gfm"; \
	elif command 2>&1 >/dev/null -v gfm;       then GFM="gfm"; fi; \
	[ "$$GFM" ] || { echo 2>&1 "No CommonMark parser installed!"; exit 2; }; \
	"$$GFM" --unsafe charmap.md \
	| sed -e 's~https://raw.githubusercontent.com/file-icons/source/master/svg/~svg/~g' \
	| sed -e 's/\(\.svg\)\?sanitize=true/\1/g' \
	> charmap.html

# Extract a downloaded IcoMoon folder
unpack:
	./bin/unpack.pl file-icons.zip
	./bin/compress.pl $(TTF)

# Clean up SVG source
svg: $(wildcard svg/*.svg)
	@./bin/clean-svg.pl $^
.PHONY: svg

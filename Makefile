all: unpack file-icons.woff2


# Extract a downloaded IcoMoon folder
unpack: file-icons.zip
	@rm -rf dist tmp icomoon.json
	@unzip -d tmp $^
	@mv tmp/fonts dist
	@mv tmp/selection.json icomoon.json
	@rm -rf tmp file-icons.zip
	@echo "Files extracted"


# Generate a WOFF2 file from a TTF
%.woff2: %.ttf
	woff2_compress $^
	


svg := $(wildcard svg/*.svg)

# Clean up SVG source
lint: $(svg)
	@dos2unix --keepdate --quiet $^
	@perl -0777 -pi -e '\
		s/<g id="icomoon-ignore">\s*<\/g>//gmi; \
		s/<g\s*>\s*<\/g>//gmi; \
		s/\s+(id|viewBox|xml:space)="[^"]*"/ /gmi; \
		s/<!DOCTYPE[^>]*>//gi; \
		s/<\?xml.*?\?>//gi; \
		s/<!--.*?-->//gm; \
		s/ style="enable-background:.*?;"//gmi; \
		s/"\s+>/">/g; \
		s/\x20{2,}/ /g; \
		s/[\t\n]+//gm;' $^


# Mark everything as phony
.PHONY: unpack lint

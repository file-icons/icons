all: unpack dist/file-icons.woff2

# Aliases
unpack: dist/file-icons.ttf


# Extract a downloaded IcoMoon folder
dist/%.ttf: %.zip
	@rm -rf dist tmp icomoon.json
	@unzip -qd tmp $^
	@mv tmp/fonts dist
	@mv tmp/selection.json icomoon.json
	@rm -rf tmp $^
	@echo "Files extracted."


# Generate a WOFF2 file from a TTF
%.woff2: %.ttf
	@[ ! -f $@ ] && { \
		hash woff2_compress 2>/dev/null || { \
			echo >&2 "WOFF2 conversion tools not found. Consult the readme file."; \
			exit 2; \
		}; \
		woff2_compress $^ >/dev/null; \
		echo "WOFF2 file generated."; \
	};
	


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


# Delete extracted files
clean:
	@rm -rf dist


.PHONY: clean
.ONESHELL:

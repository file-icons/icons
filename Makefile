charmap     := charmap.md
font-name   := file-icons
font-folder := dist
font-config := icomoon.json
png-folder  := png
png-size    := 160x160


all: unpack $(font-folder)/$(font-name).woff2

svg  := $(wildcard svg/*.svg)
png  := $(addprefix $(png-folder)/,$(patsubst %.svg,%.png,$(notdir $(svg))))


# Aliases
unpack:  $(font-folder)/$(font-name).ttf
charmap: $(charmap)


# Extract a downloaded IcoMoon folder
$(font-folder)/%.ttf: %.zip
	@rm -rf $(font-folder) tmp $(font-config)
	@unzip -qd tmp $^
	@mv tmp/fonts $(font-folder)
	@mv tmp/selection.json $(font-config)
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



# Routine to compress PNGs with TinyPNG, if an API key is available
ifdef TINYPNG_KEY
define minify
echo "Compressing image with TinyPNG...";
URL=$$(curl https://api.tinify.com/shrink \
	--user api:$(TINYPNG_KEY) \
	--data-binary @$1 \
	--silent | grep -Eo '"url":"https[^"]+"' | cut -d: -f 2-3 | tr -d '"'); \
echo "Downloading from $$URL"; \
curl $$URL --user api:$(TINYPNG_KEY) --silent --output $1
echo "Compression complete."
endef
endif


# Generate PNG versions of each SVG and update character map
icon-previews: png $(png)


# Generate a PNG from an SVG file
$(png-folder)/%.png: svg/%.svg
	@mogrify \
		-filter Catrom \
		-background none \
		-thumbnail $(png-size) \
		-format png \
		-path $(png-folder) $<
	@echo "Generated: $(notdir $@)"
	@$(call minify,$@)


# Create the PNG directory if it doesn't exist yet
$(png-folder):
	mkdir -p $@


# Generate/update character map
$(charmap):
	@./create-map.pl $(font-folder)/$(font-name).svg $@


# Update the charmap's "Name" column using each row's "data-s" attribute
synced-names:
	@perl -p -i -e 's/(<tbody data-s=")([^"]+)(".+<b>)[^<]+(<\/b>.+$$)/$$1$$2$$3$$2$$4/gmi' $(charmap)



# Reset unstaged changes/additions in object directories
clean:
	@git clean -fd $(font-folder)
	@git clean -fd $(png-folder)
	@git checkout -- $(font-folder) 2>/dev/null || true
	@git checkout -- $(png-folder)  2>/dev/null || true


# Delete extracted and generated files
distclean:
	@rm -rf $(font-folder)
	@rm -rf $(png-folder)


.PHONY: clean distclean $(charmap)
.ONESHELL:

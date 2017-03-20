charmap     := charmap.md
font-name   := file-icons
font-folder := dist
font-config := icomoon.json
icon-size   := 34
icon-folder := svg
repo-name   := file-icons/source
install-dir := ~/Library/Fonts
svg-files   := $(wildcard $(icon-folder)/*.svg)
last-commit  = $(shell git log -1 --oneline --no-abbrev | cut -d' ' -f1)


all: unpack install prune charmap relink


# Aliases
unpack:  $(font-folder)/$(font-name).woff2
charmap: $(charmap)


# Extract a downloaded IcoMoon folder
$(font-folder)/%.woff2: %.zip
	@rm -rf $(font-folder) tmp $(font-config)
	@unzip -qd tmp $^
	@mv tmp/fonts $(font-folder)
	@mv tmp/selection.json $(font-config)
	@rm -rf tmp $^
	@perl -pi -e 's|^( {2})+|"\t" x (length($$&)/2)|ge' $(font-config)
	@echo "" >> $(font-config) # Ensure trailing newline
	@echo "Files extracted."
	@[ ! -f $@ ] && { \
		hash woff2_compress 2>/dev/null || { \
			echo >&2 "WOFF2 conversion tools not found. Consult the readme file."; \
			exit 2; \
		}; \
		output=$$(woff2_compress $(font-folder)/$*.ttf 2>&1 >/dev/null) || { \
			echo >&2 "WOFF2 conversion failed with error $$?:"; \
			echo "$$output" | sed 's/^/\t/g'; \
			exit 2; \
		}; \
		echo "WOFF2 file generated."; \
	};


install: $(install-dir)/$(font-name).ttf

# Install the TrueType version of an unpacked font
$(install-dir)/$(font-name).ttf: $(install-dir)
	@rm -f $@
	@cp $(font-folder)/$(font-name).ttf $@
	@echo >&2 "System-installed font updated."


# Delete unneeded font files
prune:
	@rm -f $(font-folder)/$(font-name).{eot,ttf,woff}



# Clean up SVG source
svg: $(svg-files)
	@./clean-svg.pl $^



# Generate/update character map
$(charmap):
	@./create-map.pl -r=$(repo-name) -i=$(icon-folder) --size=$(icon-size) $(font-folder)/$(font-name).svg $@




# Reattach broken hard links after extracting files
relink: $(font-folder)/$(font-name).woff2
	@[ -d $(FILE_ICONS) ] && { \
		target=$(FILE_ICONS)/fonts/file-icons.woff2; \
		[ $$(stat -f %m $<) != $$(stat -f %m "$$target") ] && \
		ln -f $< $(FILE_ICONS)/fonts/file-icons.woff2 && \
		echo >&2 "Hard links reconnected."; \
	} || true;



# Force an icon's preview to be refreshed on GitHub
cachebust:
	@$(call need-var,icon,ERROR_NO_ICON)
	@base="https://cdn.rawgit.com/Alhadis/FileIcons/"; \
	perl -pi -e 's{$$base\K\w+(?=/svg/$(icon:%.svg=%)\.svg")}{$(last-commit)}ig;' $(charmap)


# Dummy task to improve feedback if `cachebust` is mistyped
icon:
	$(call need-var,,ERROR_UNDEF_ICON)



.PHONY: $(charmap) install cachebust icon prune svg
.ONESHELL:


# Error message shown to users attempting to run `make relink` without a link
ERROR_NO_PKG := Environment variable FILE_ICONS not found. \
	| \
	| Try this instead:\
	| \
	| \	make relink FILE_ICONS=/path/to/your/file-icons/installation | 


# Error message shown when running `make cachebust` without an icon
ERROR_NO_ICON := No icon specified. Task aborted.| \
	| Usage: \
	| \	make icon=file[.svg] cachebust \
	| \
	| Examples: \
	| \	make icon=Manpage cachebust \
	| \	make icon=APL.svg cachebust | 


# Shown if user tries running `make icon NAME cachebust` by mistake
ERROR_UNDEF_ICON := No task named \"icon\". \
	| \
	| Did you mean this? \
	| \	make icon=NAME cachebust | 
	


# If the given value is empty, die with an error message
need = @$(if $(1),,echo $(subst | ,$$'\n',$(2)); exit 2)

# Like `need`, but uses variable names instead of string values
need-var = @$(call need,$($(1)),$($(2)))

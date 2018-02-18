all:
	

# Update character map
charmap:
	./bin/update-charmap.pl

# Extract a downloaded IcoMoon folder
unpack: file-icons.zip
	./bin/unpack.pl $^

# Clean up SVG source
svg: $(wildcard svg/*.svg)
	@./bin/clean-svg.pl $^

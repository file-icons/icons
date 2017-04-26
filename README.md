File Icons
==========

This is the source for the [File-Icons](https://github.com/file-icons/atom) package's custom icon-font.

Please [submit a request](https://github.com/file-icons/source/issues) if an icon is missing.


Exporting icons
---------------
If you're exporting an icon from a graphics program, make sure you've optimised it:

1. Outline paths, and delete hidden or unused geometry.
2. Leave everything ungrouped. Compound paths are enough.
3. Merge duplicate control points. Simplify paths if possible.
4. Export with the *maximum* permitted number of decimal spaces.  
	* **Adobe Illustrator:** Use <kbd>File → Save as…</kbd>, not <kbd>Export as…</kbd>
	* **Inkscape:** Save as "Plain SVG", not "Inkscape SVG"
5. Run `make lint` to clean up source code.


Requirements for maintainers
----------------------------
* [Perl 5](https://www.perl.org/)
* [GNU Make](http://www.gnu.org/software/make/manual/make.html)
* [WOFF2 Encoder](https://github.com/google/woff2)

macOS already ships with Perl and Make installed. The remaining dependencies can be installed with [Homebrew](http://brew.sh/):

	brew install bramstein/webfonttools/woff2

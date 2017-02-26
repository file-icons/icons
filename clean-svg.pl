#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

sub clean_svg {
	my $input;
	my $name = $_[0];
	local $/=undef;
	
	open(SVG, $name);
	while(<SVG>){ $input = $_; }
	close SVG;
	
	$_ = $input;
	s/\r\n/\n/g;
	s/<g id="icomoon-ignore">\s*<\/g>//gmi;
	s/<g\s*>\s*<\/g>//gmi;
	s/\s+(id|viewBox|xml:space)="[^"]*"/ /gmi;
	s/<!DOCTYPE[^>]*>//gi;
	s/<\?xml.*?\?>//gi;
	s/<!--.*?-->//gm;
	s/ style="enable-background:.*?;"//gmi;
	s/"\s+>/">/g;
	s/\x20{2,}/ /g;
	s/[\t\n]+//gm;
	
	# Only write back if something changed
	if($input ne (my $output = $_)){
		open(SVG, ">", $name);
		print SVG $output;
		close(SVG);
	}
}

for (@ARGV) {
	clean_svg $_;
}

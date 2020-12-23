#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use v5.14;
use utf8;
$| = 1;

use warnings  qw< FATAL utf8 >;
use open      qw< :std :utf8 >;
use charnames qw< :full >;
use feature   qw< say unicode_strings >;
use Carp      qw< confess >;

use File::Spec::Functions qw< rel2abs >;
use File::Basename qw< basename >;
use Data::Dumper;
use Cwd;


# Name of field used for storing the original line number of a TSV record
our $lineKey = "\tline";

# Load an ASCII database with tab-delimited fields
sub readTSV {
	open(my $fh, "< :encoding(UTF-8)", shift);
	($_ = <$fh>) =~ s/^# *|\R$//g;
	my @headers = split /\t/;
	my @table = ();
	while(<$fh>){
		chomp;
		my %row = ();
		my @cols = split /\t/;
		push @cols, "" while $#cols < $#headers;
		@row{@headers} = @cols;
		$row{$lineKey} = $.;
		push @table, \%row;
	}
	close $fh;
	return @table;
}

# Organise the result of parsing `icons.tsv` into an array
sub groupIcons {
	my %fonts = ();
	foreach(@_){
		my %icon = %$_;
		my $fontName = $icon{"Font"};
		unless(defined $fonts{$fontName}){
			$fonts{$fontName} = {
				name => $fontName,
				icons => {},
			};
		}
		my %font = %{$fonts{$fontName}};
		(my $code = $icon{"Codepoint"}) =~ s/^U\+//i;
		$code = hex($code);
		
		# There shouldn't be duplicate codepoints, so holler out if we find one
		if(defined $font{"icons"}{$code}){
			printf STDERR 'Codepoint U+%04X already assigned to "%s" icon in "%s" font (line %s)' . $/,
				$code, $font{"icons"}{$code}{"Name"}, $fontName, $icon{$lineKey};
			exit 2;
		}
		$font{"icons"}{$code} = \%icon;
	}
	return %fonts;
}

# Print a one-line usage summary to stdout, then exit
sub usage {
	my ($B, $b) = (-t 1) ? ("\e[1m", "\e[22m") : ("", "");
	my ($U, $u) = (-t 1) ? ("\e[4m", "\e[24m") : ("", "");
	printf "Usage: ${B}\%s${b} [${U}\%s${u}] [${U}\%s${u}]\n",
		basename($0), "/path/to/icons.less", "/path/to/icons.tsv";
	exit($_[0] || 0);
}


# Resolve source and destination files
my $css_path = $ARGV[0] || Cwd::abs_path "$ENV{HOME}/.atom/packages/file-icons/styles/icons.less";
my $tsv_path = $ARGV[1] || Cwd::abs_path(rel2abs("../../icons.tsv", "$0"));
usage(1) unless -r $css_path;
usage(1) unless -r $tsv_path;

# Load the current icon-table
my @table = readTSV($tsv_path);
my %fonts = groupIcons(@table);
say Dumper(\%fonts);

__END__

# Load the individual icon rules
open(my $fh, "< :encoding(UTF-8)", $css_path) or die("Couldn't open icons.less: $!");
my %fonts = ();
foreach(@rules){
	chomp;
	if(m/^\.[_a-z][-\w]+-icon:before /) and m/}$/;
	
	say;
}

#!/usr/bin/env perl
use strict;
use warnings;
use feature "say";
use Data::Dumper;
use Getopt::Long qw(:config auto_abbrev);


# Parse options
my $size=34;
my $repo="";
my $icon_folder="svg";
GetOptions(
	"size=i"        => \$size,
	"repo=s"        => \$repo,
	"icon-folder=s" => \$icon_folder
);


# Query author/repo from shell if not supplied
unless($repo){
	$repo = `git remote get-url origin`;
	$repo =~ m/:(.+)\.git$/;
	$repo = $1;
}


my $input_path  = $ARGV[0];
my $output_path = $ARGV[1];

sub warnMissing {
	printf STDERR "No %s file specified.\n", $_[0];
	my $usage = "\x1B[1mUSAGE:\x1B[0m $0 input output\n";
	$usage =~ s/$_[0]/[\x1B[4m$&\x1B[0m]/i;
	printf STDERR $usage;
}

# Argument checking
unless($input_path) { warnMissing "input";  exit 2; }
unless($output_path){ warnMissing "output"; exit 2; }


my %codepoints = ();
my %table_rows = ();
my $output_src;


# Load existing character map
open(my $fh, "< :encoding(UTF-8)", $output_path);
{
	local $/=undef; # Slurp

	while(<$fh>){
		
		# Store file's contents for later
		$output_src = $_;
		
		# Grab which codepoints are already listed
		while($_ =~ m/<tbody.+<a name="([^"]+)".+<code>\\([0-9A-Fa-f]+)<\/code>.+<\/tbody>/ig){
			$codepoints{$2} = $1;
			$table_rows{$1} = $&;
		}
	}
	close($fh);
}

my $url = "https://cdn.rawgit.com/$repo/master/svg/%1\$s.svg";
my $row = '<tbody><tr><td align="center"><a name="%1$s" href="' . $url . '"><img src="' . $url .
	'" height="34" valign="bottom" hspace="3" alt=""/></a></td><td><b>%1$s</b></td><td><code>\\%2$s</code></td></tr></tbody>';


# Pick up newly-defined characters from SVG font
while(<>){
	my $line = $_;
	
	if($line =~ /^\s*<glyph\s+unicode="&#x([0-9A-Fa-f]+);?"\s+glyph-name="([^"]+)"/ && $1){
		my $code = uc $1;
		my $name = ucfirst($2 =~ tr/-/ /r);
		
		# Avoid clobbering existing rows that might've been edited by user
		unless($codepoints{$code}){
			$codepoints{$code} = $name;
			$table_rows{$name} = sprintf $row, $name, $code;
		}
	}
}


# Grab an alphabetised list of entry names
my @sorted_names = sort { lc($a) cmp lc($b) } keys %table_rows;


my $updated_rows = join "\n", map { $table_rows{$_} } @sorted_names;
$updated_rows =~ s/^/\t/gm;

# Replace the character map's existing table rows
$output_src =~ s/\s*<tbody.+(<\/table>)/\n$updated_rows\n$1/sgmi;

open($fh, "> :encoding(UTF-8)", $output_path);
print $fh $output_src;

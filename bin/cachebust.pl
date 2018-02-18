#!/usr/bin/env perl

=head1 NAME

cachebust - Force an icon's preview to be refreshed on GitHub

=head1 USAGE

B<cachebust> Icons.svg Which.svg Changed.svg...

=cut

use strict;
use warnings;
use autodie;
use v5.14;
use utf8;
$| = 1;

use warnings qw< FATAL utf8 >;
use open     qw< :std :utf8 >;

use File::Basename qw< basename >;
use File::Path qw< rmtree >;
use File::Copy;
use File::Spec::Functions qw< :ALL >;

# Switch to project's root directory
chdir Cwd::abs_path(rel2abs("../..", "$0"));
my ($lastCommit) = split " ", `git log -1 --oneline --no-abbrev`;

# <cartoonish-sucking-noise.wav>
my $charmap = do {{
	local $/ = undef;
	local @ARGV = ("charmap.md");
	join "", <>;
}};

for(@ARGV){
	my $icon = ($_ =~ s/\.svg$//i);
	my $base = "https://cdn.rawgit.com/(Alhadis|file-icons)/(FileIcons|source)/";
	$charmap =~ s|$base\K\w+(?=/svg/$icon)\.svg"|$lastCommit|ig;
}

open(my $fh, ">", "charmap.md");
print $fh $charmap;

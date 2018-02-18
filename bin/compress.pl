#!/usr/bin/env perl
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

# Locate an executable in the user's $PATH
sub which {
	my $program = shift;
	$_ = `which "$program" 2>/dev/null`;
	chop;
	return $_;
}

# Switch to project's root directory
chdir Cwd::abs_path(rel2abs("../..", "$0"));

my $woffBin = which "woff2_compress";
if(!$woffBin){
	say 'WOFF2 conversion tools not found in $PATH.';
	
	$woffBin = "woff2/woff2_compress";
	if(-x $woffBin){
		say "Using previously-built binary.";
	}
	else{
		# Hold onto your butts
		say "Building from source...";
		`git clone --recursive https://github.com/google/woff2.git` or die $@;
		my $make = which("gmake") ? "gmake" : "make";
		`cd woff2 && ${make} clean all` or die "Failed to build WOFF2 binaries: $@\n";
	}
}

for(@ARGV){
	my $feedback = `"$woffBin" "$_" 2>&1`;
	if($?){
		say "WOFF2 conversion failed with error $?:";
		$feedback =~ s/^/\t/gm;
		say $feedback;
		exit 2;
	}
	say "WOFF2 file generated.";
}

#! /usr/local/bin/perl -w

use warnings;
use strict;

my ($input, $output) = 0;

$input = $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

$output = "$input.ext";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";

open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
    if(/^NC_045512\.2\t+(\d+)\t+\S\t+(\S+)\t+(\S+)\t+\S+\t+\S+\t+(\S+)/){
        print OUTPUT "$1\t$2\t$3\t$4\n";
    }
}
close INPUT;
close OUTPUT;
exit

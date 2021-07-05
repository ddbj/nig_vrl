#! /usr/bin/perl -w

use warnings;
use strict;

my ($input, $output) = 0;

$input = $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

$output = "$input.Low.vcf";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";

open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
    if(/^((NC_045512\.2\t+\d+\t+\S+\t+(\S))\t+(\S)\t+(\S+\t+\S+\t+DP\S(\S+?)\;DPS\S.+?))\s*$/){
        if($6 < 10){
            print OUTPUT "$2\tN\t$5\n";
        }
        else{
            print OUTPUT "$1\n";
        }
    }
    else{
        print OUTPUT $_;
    }
}
close INPUT;
close OUTPUT;
exit;

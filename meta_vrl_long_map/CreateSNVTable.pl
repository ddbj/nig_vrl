#! /usr/bin/perl -w

use warnings;
use strict;

my ($input, $output, $output2, $first) = 0;

$input = $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

$output = "$input.snv";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";

$output2 = "$input.snv.S";
open(OUTPUT2, ">$output2") or die "Can't open \"$output2\"\n";

$first = 0;
print OUTPUT2 "$input\t";
open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
    if(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=INTERGENIC/){
        print OUTPUT "$1\t$1 \($2 to $3\)\tIntergenic\n";
    }
    elsif(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=SYNONYMOUS_CODING\S+?\|([A-Z0-9]+)\|\d+?\|(\S+?)\|protein_coding/){
        print OUTPUT "$1\t$4\t$5\n";
        if($5 eq "S"){
            if($first == 0){
                print OUTPUT2 "$4";
                $first = 1;
            }
            else{
                print OUTPUT2 ", $4";
            }
        }
    }
    elsif(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=NON_SYNONYMOUS_CODING\S+?\|([A-Z0-9]+)\|\d+?\|(\S+?)\|protein_coding/){
        print OUTPUT "$1\t$4\t$5\n";
        if($5 eq "S"){
            if($first == 0){
                print OUTPUT2 "$4";
                $first = 1;
            }
            else{
                print OUTPUT2 ", $4";
            }
        }
    }
    elsif(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=FRAME_SHIFT\S+?\|([A-Z0-9]+)\|\d+?\|(\S+?)\|protein_coding/){
        print OUTPUT "$1\t$4 \($2 to $3 frame shift\)\t$5\n";
        if($5 eq "S"){
            if($first == 0){
                print OUTPUT2 "$4 \($2 to $3 frame shift\)";
                $first = 1;
            }
            else{
                print OUTPUT2 ", $4 \($2 to $3 frame shift\)";
            }
        }
    }
    elsif(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=CODON_DELETION\S+?\|([A-Z0-9]+)\|\d+?\|(\S+?)\|protein_coding/){
        print OUTPUT "$1\t$4 Deletion\t$5\n";
        if($5 eq "S"){
            if($first == 0){
                print OUTPUT2 "$4 Deletion";
                $first = 1;
            }
            else{
                print OUTPUT2 ", $4 Deletion";
            }
        }
    }
    elsif(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=CODON_CHANGE_PLUS_CODON_DELETION\S+?\|([A-Z0-9]+)\|\d+?\|(\S+?)\|protein_coding/){
        print OUTPUT "$1\t$4\t$5\n";
        if($5 eq "S"){
            if($first == 0){
                print OUTPUT2 "$4";
                $first = 1;
            }
            else{
                print OUTPUT2 ", $4";
            }
        }
    }
    elsif(/^(\S+)\t+(\S+)\t+(\S+)\t+\S+?\;EFF=STOP_GAINED\S+?\|([A-Z0-9]+\*)\|\d+?\|(\S+?)\|protein_coding/){
        print OUTPUT "$1\t$4\t$5\n";
        if($5 eq "S"){
            if($first == 0){
                print OUTPUT2 "$4";
                $first = 1;
            }
            else{
                print OUTPUT2 ", $4";
            }
        }
    }
    else{
        print "$_";
    }
}
close INPUT;
close OUTPUT;
print OUTPUT2 "\n";
close OUTPUT2;
exit;

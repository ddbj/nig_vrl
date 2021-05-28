#! /usr/bin/perl -w

use warnings;
use strict;

my ($input, $output, $TTTA) = 0;

$input = $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

$output = "$input.filter.vcf";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";

$TTTA = 0;
open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
    if(/^(NC_045512\.2\t21990\t+\S+\t+TTTA\t+T\t+\S+\t+\S+\t+\S.+?)\s*$/){
        print OUTPUT "$1\n";
        $TTTA = 1;
    }
    elsif(/^NC_045512\.2\t21991\t+\S+\t+TTA\t+T\t+(\S+\t+\S.+?\;)EFF\=\S.+?\s*$/){
        if($TTTA == 1){
            next;
        }
        else{
            print OUTPUT "NC_045512\.2\t21990\t\.\tTTTA\tT\t$1\;EFF\=CODON_CHANGE_PLUS_CODON_DELETION\(MODERATE\|\|tattac\/tac\|YY144Y\|1273\|S\|protein_coding\|CODING\|GU280_gp02\|1\|T\|INFO_REALIGN_3_PRIME\)  GT\:GQ   1\/1\:31\n";
            $TTTA = 1;
        }
    }
    elsif(/^NC_045512\.2\t21992\t+\S+\t+TA\t+T\t+(\S+\t+\S.+?\;)EFF\=\S.+?\s*$/){
        if($TTTA == 1){
            next;
        }
        else{
            print OUTPUT "NC_045512\.2\t21990\t\.\tTTTA\tT\t$1\;EFF\=CODON_CHANGE_PLUS_CODON_DELETION\(MODERATE\|\|tattac\/tac\|YY144Y\|1273\|S\|protein_coding\|CODING\|GU280_gp02\|1\|T\|INFO_REALIGN_3_PRIME\)  GT\:GQ   1\/1\:31\n";
        }
    }
    else{
        print OUTPUT $_;
    }
}
close INPUT;
close OUTPUT;
exit;

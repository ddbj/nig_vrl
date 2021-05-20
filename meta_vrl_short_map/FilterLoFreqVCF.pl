#! /usr/bin/perl -w

use warnings;
use strict;

my ($input, $output, $all, $position, $aadif, $dep, $af, $remD61, $d3h, $d3v, $d3e, $r203k, $r203, $g204r) = 0;

$input = $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

$output = "$input.filter";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";

$remD61 = 0;
$d3h = 0;
$d3v = 0;
$d3e = 0;
$r203k = 0;
$r203 = 0;
$g204r = 0;

open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
    if(/^((\d+)\t+(\S.+?)\t+\S+\t+(\S+)\t+(\S+))\s*$/){
        $all = $1;
        $position = $2;
        $aadif = $3;
        $dep = $4;
        $af = $5;
        #Remove Primer artifact
        if($position == 27384){
            if($aadif eq "D61"){
                if($af < 0.9){
                    $remD61 = 1;
                }
            }
        }
        #
        elsif($position == 28280){
            if($aadif eq "D3H"){
                $d3h = 1;
            }
        }
        elsif($position == 28281){
            if($aadif eq "D3V"){
                $d3v = 1;
            }
        }
        elsif($position == 28282){
            if($aadif eq "D3E"){
                $d3e = 1;
            }
        }
        elsif($position == 28881){
            if($aadif eq "R203K"){
                $r203k = 1;
            }
        }
        elsif($position == 28882){
            if($aadif eq "R203"){
                $r203 = 1;
            }
        }
        elsif($position == 28883){
            if($aadif eq "G204R"){
                $g204r = 1;
            }
        }
    }
}
close INPUT;

open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
    if(/^((\d+)\t+(\S.+?)\t+\S+\t+(\S+)\t+(\S+))\s*$/){
    $all = $1;
    $position = $2;
    $aadif = $3;
    $dep = $4;
    $af = $5;
    if($position == 27384){
        if($remD61 == 1){
            next;
        }
        else{
            print OUTPUT "$all\n";
        }
    }
    elsif($position == 28280){
        if($d3h == 1 && $d3v == 1 && $d3e == 1){
            print OUTPUT "28280\tD3L\tN\t$dep\t$af\n";
        }
        else{
            print OUTPUT "$all\n";
        }
    }
    elsif($position == 28281){
            if($d3h == 1 && $d3v == 1 && $d3e == 1){
                next;
            }
            else{
                print OUTPUT "$all\n";
            }
    }
    elsif($position == 28282){
            if($d3h == 1 && $d3v == 1 && $d3e == 1){
                next;
            }
            else{
                print OUTPUT "$all\n";
            }
    }
    elsif($position == 28881){
            if($r203k == 1 && $r203 == 1 && $g204r == 1){
                print OUTPUT "28881\tRG203KR\tN\t$dep\t$af\n";
            }
            else{
                print OUTPUT "$all\n";
            }
    }
    elsif($position == 28882){
            if($r203k == 1 && $r203 == 1 && $g204r == 1){
                next;
            }
            else{
                print OUTPUT "$all\n";
            }
    }
    elsif($position == 28883){
            if($r203k == 1 && $r203 == 1 && $g204r == 1){
                next;
            }
            else{
                print OUTPUT "$all\n";
            }
    }
    else{
        print OUTPUT "$all\n";
    }
    }
    else{
        print "No match: $_";
    }
}
close INPUT;
close OUTPUT;
exit;

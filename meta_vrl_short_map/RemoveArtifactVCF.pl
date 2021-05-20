use warnings;
use strict;

my ($input, $output) = 0;

$input = $ARGV[0];
open(INPUT, "$input") or die "Can't open \"$input\"\n";

$output = "$input.filter.vcf";
open(OUTPUT, ">$output") or die "Can't open \"$output\"\n";

open(INPUT, "$input") or die "Can't open \"$input\"\n";
while(<INPUT>){
#Remove primer artifact 
    if(/^(NC_045512\.2\t+27384\t+\S+\t+T\t+C\t+\S+\t+\S+\t+DP\=(\d+)\;AF\=(\S+?)\;SB.+?)\s*$/){
        if($2 >= 1000){
            if($3 >= 0.9){
                print OUTPUT "$1\n";
            }
        }
    }
    else{
        print OUTPUT $_;
    }
}
close INPUT;
close OUTPUT;
exit;

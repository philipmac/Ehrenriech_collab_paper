# the headers of the rep file breaks bowtie, just replace them with numbers. 

use warnings;
use strict;

open OUT, ">data/DRdatabase_simple.txt" or die $!;
open MAP, ">data/map.txt" or die $!;
open IN, "data/DRdatabase.txt" or die $!;

my $int=1;
while (<IN>){
    if ($_ =~ />/){
	print OUT ">$int\n";
	print MAP $int,"\t",$_;
	$int++;
    }
    else{
	print OUT $_;
    }
}
close IN;
close OUT;
	

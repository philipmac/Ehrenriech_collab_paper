# this is going towards making a call of which species is nearest each sample (contig set).
# note, we are dealing with total number of genes here, not number of loci

use warnings;
use strict;
my @contigSets = `ls ../ecolireads/`;


foreach my $contigSet (@contigSets){
    chomp $contigSet;
    next unless $contigSet =~/_31/;


    my %strainToNumHits;
    my @strains= `ls ../ecolireads/$contigSet/blat/gene_calls/Esch*`;

    foreach my $strainPath (@strains){
    	chomp $strainPath;
    	my @a = split /\//,$strainPath;
    	my $strain = $a[$#a];
    	$strain=~ s/\.csv//;
    	my ($wcl,undef) = split /\s+/,`wc -l $strainPath`;
    	chomp $wcl;
    	$strainToNumHits{$strain}=$wcl;
    }

    open OUT, ">gene_counts/$contigSet" or die $!;
    foreach (sort {$strainToNumHits{$b}<=>$strainToNumHits{$a}} (keys %strainToNumHits)){
    	print OUT $strainToNumHits{$_},"\t",$_,"\n";
    }
    close OUT;
}



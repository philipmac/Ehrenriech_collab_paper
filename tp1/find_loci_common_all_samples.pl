# this gets the loci and orders them by count over sample
# some cutoff can then be applied to the output file for 'common to all' sets and so on.

use warnings;
use strict;


my %hash;
my @files = `ls ../ecolireads/*/blat/gene_calls/all_strains.genes_hit`;
foreach my $file (@files){    
    chomp $file;
    my (undef,undef,$ctg,undef)=split /\//,$file;
    $ctg =~ s/_31//;

    open IN, "$file" or die $!;
    while (<IN>){
    	chomp;
    	my (undef,$loci)=split /\t/,$_;
    	my @locis = split /,/,$loci;
    	foreach (@locis){
    	    $hash{$_}{$ctg}=1;
    	}
    }
    close IN;

}

open OUT, ">derived_data/loci_samples_ordered_occurence.csv";
foreach my $locus(sort {sk($b) <=> sk($a)} keys %hash){
    my %h=%{$hash{$locus}};
    my $numStrainsLocusSeen = scalar keys %h;
    my $listOfStrains = join ",", (keys %h);
    my %notSeen;
    print OUT join "\t",($locus,$numStrainsLocusSeen,"\n"); # $listNotStrains, ,$listOfStrains
}
close OUT;

sub sk{
    return scalar keys %{$hash{$_[0]}}
}

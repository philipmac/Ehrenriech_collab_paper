# Order loci wrt host
# <locus> <occ num hosts> (there are five hosts in all.
# some cutoff can then be applied to the output file for 'common to all' sets and so on.

use warnings;
use strict;
my %contigToHost;
open IN, "derived_data/top_picks_merged_with_Ian_work" or die $!;
while(<IN>){
    # barcode E_coli_strain_called             num_genes_common type host
    # AATGGC  Escherichia_coli_CFT073_uid57915 3259             5    4
    chomp;
    next if $_ =~ /barcode|^\s?$/;
    my ($contig,undef,undef,undef,$host)=split /\t/,$_;
    $contigToHost{$contig} = $host;
}
close IN;

my %hash;
my @bests = `ls best_strain`;
foreach my $best (@bests){    
    chomp $best;
    my ($ctg,undef)=split /_31\./,$best;
    open IN, "derived_data/best_strain/$best" or die $!;
    while (<IN>){
	chomp;
	my (undef,$loci)=split /\t/,$_;
	my @locis = split /,/,$loci;
	foreach (@locis){
	    $hash{$_}{$contigToHost{$ctg}}=1;
	}
    }
    close IN;
}

open OUT, ">derived_data/loci_samples_ordered_indiv.csv";
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

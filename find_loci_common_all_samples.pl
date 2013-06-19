# this script just gets the loci and orders them by count over sample
# some cutoff can then be applied to the output file for 'common to all' sets and so on.

use warnings;
use strict;


my %hash;
my @bests = `ls best_strain`;
foreach my $best (@bests){    
    chomp $best;
    my ($ctg,undef)=split /_31\./,$best;
    open IN, "best_strain/$best" or die $!;
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

open OUT, ">loci_samples_ordered_occurence.csv";
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

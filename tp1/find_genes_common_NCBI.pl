# open the ortho mapper file derived_data/map_withEcoGene
# look up all the strains in study derived_data/strains_used
# write out in descending order of frequency of occurrence across all strains each traditional locus name 

use warnings;
use strict;

# locus => strain

my %locusToStrain;
open IN, "derived_data/map_withEcoGene" or die$!;
while(<IN>){
    # Escherichia_coli_042_uid161985 \t NC_017626 \t 336-2798 \t LOCUSTAG: EC042_0001 \t LOCUS: thrA \t SYNS:  ECOGENE: EG10998 GENEID: 
    my ($str,undef,undef, undef,$locStr,undef) = split /\t/, $_;
    $locStr =~ s/LOCUS:|\s+//g;
    ${$locusToStrain{$locStr}}{$str}=1 if $locStr ne '';
}
close IN;


my %allStrains;
open IN, "derived_data/strains_used" or die $!;
while (<IN>){
    chomp $_;
    my $str=$_;
    $str=~s/\.\.|\/|ECO_ALL|://g;
    $allStrains{$str}=1;
}
close IN;
# print join "\n", keys %allStrains;
# exit;


open OUT, ">derived_data/locus_to_num_times_seen_NCBI_all.csv";
foreach my $locus(sort {sk($b) <=> sk($a)} keys %locusToStrain){
    my %h=%{$locusToStrain{$locus}};
    my $numStrainsLocusSeen = scalar keys %h;
    my $listOfStrains = join ",", (keys %h);
    my %notSeen;
    foreach (keys %allStrains){
	next if $h{$_};
	$notSeen{$_}=1;
    }
    my $listNotStrains=join ',', keys %notSeen;
    print OUT join "\t",($locus,$numStrainsLocusSeen,$listOfStrains,$listNotStrains, "\n"); # 
}
close OUT;

sub sk{
    return scalar keys %{$locusToStrain{$_[0]}}
}

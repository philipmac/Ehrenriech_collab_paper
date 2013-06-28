use warnings;
use strict;

# locus strain

my %locusToStrain;
open IN, "map_withEcoGene" or die$!;
while(<IN>){
    # Escherichia_coli_042_uid161985 \t NC_017626 \t 336-2798 \t LOCUSTAG: EC042_0001 \t LOCUS: thrA \t SYNS:  ECOGENE: EG10998 GENEID: 
    my ($str,undef,undef, undef,$locStr,undef) = split /\t/, $_;
    $locStr =~ s/LOCUS:|\s+//g;
    ${$locusToStrain{$locStr}}{$str}=1 if $locStr ne '';
}
close IN;


my %allStrains;
open IN, "strains_used" or die $!;
while (<IN>){
    chomp $_;
    my $str=$_;
    $str=~s/\.\.|\/|ECO_ALL|://g;
    $allStrains{$str}=1;
}
close IN;
# print join "\n", keys %allStrains;
# exit;


open OUT, ">locus_to_num_times_seen_NCBI_all";
foreach my $locus(sort {scalar keys %{$locusToStrain{$b}} <=> scalar (keys %{$locusToStrain{$a}})} keys %locusToStrain){
    my %h=%{$locusToStrain{$locus}};
    my $numStrainsLocusSeen = scalar keys %h;
    my $listOfStrains = join ",", (keys %h);
    my %notSeen;
    foreach (keys %allStrains){
	next if $h{$_};
	$notSeen{$_}=1;
    }
    my $listNotStrains=join ',', keys %notSeen;
    print OUT join "\t",($locus,$numStrainsLocusSeen,"\n"); # $listNotStrains, $listOfStrains
}
close OUT;

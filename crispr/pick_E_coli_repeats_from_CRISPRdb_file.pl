# the file Spacerdatabase.txt is downloaded from http://crispr.u-psud.fr/crispr/BLAST/Spacer/Spacerdatabase on Mon Aug  5 11:38:30 EDT 2013
# not all repeats are e coli repeats
# I only want the Ecoli repeats for the time being. 
# use the mapper file to get these. 

use strict;
use warnings;
open IN, "data/NC_NAME_E_coli.txt" or die $!;
my %nc_to_sp;
while(<IN>){
    chomp $_;
    my @l = split /\t/,$_;
    $nc_to_sp{$l[0]}=$l[1];
}
close IN;

open IN, "data/DRdatabase.txt";
open OUT, ">data/repeat_database_Ecoli.txt" or die $!;
my $ecoli=0;
while (<IN>){
    chomp $_;
    if ($_ =~ /^>/){
	my $tmp = $_;
	$tmp =~ s/>//;
	my @ncs = split /\|/,$tmp;
	foreach (@ncs){
	    my @nc = split /_/,$_;
	    my $nc_name = $nc[0].'_'.$nc[1];

	    if($nc_to_sp{$nc_name}) { $ecoli=1 }
	    else{ $ecoli=0 }
	}
    }

    if( $ecoli ){
	print OUT "$_\n";

	if ($_ !~ /^>/){ $ecoli = 0 }
    }
}
close IN;
close OUT;

    

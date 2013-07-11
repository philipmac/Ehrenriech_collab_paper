
use warnings;
use strict;

open IN, "../tp1/derived_data/EGname_to_Tradname.csv" or die $!;
my %trad_to_eg;
while (<IN>){
    chomp;
    my ($eg,$trad) = split /\t/,$_;
    $trad_to_eg{$trad}=$eg;
}


my @files = `ls ~/e_reich/tp2/reads/*/k_31_covg_30/blat/*.gene_calls`;

foreach my $file (@files){    
    chomp $file;
    my (undef,undef,$ctg,undef)=split /\//,$file;
    $ctg =~ s/_31//;

    my %ecogenes;
    open IN, "$file" or die $!;
    while (<IN>){

    	chomp;
    	my (undef,$loci)=split /\t/,$_;
    	my @locis = split /,/,$loci;


    	foreach (@locis){	    	    
    	    $ecogenes{$trad_to_eg{$_}}=1 if defined $trad_to_eg{$_};
    	}
    }
    close IN;
 
    my $outFile = $file;
    $outFile =~ s/gene_calls/ECO_GENES_hit/;

    open OUT, ">$outFile" or die $!;
    print OUT join "\n", (sort {$a cmp $b} keys %ecogenes);
    close OUT;
}

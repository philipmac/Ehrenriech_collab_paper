# assemble all of the best species picks into one place...

use strict;
use warnings;

open (IN, "top_picks_merged_with_Ian_work") or die $!;

while (<IN>){

    #barcode E_coli_strain_called num_genes_common type host
    #AATGGC Escherichia_coli_CFT073_uid57915 3259 5 4
    chomp;
    next if $_ =~ /barcode/i;
    my ($sample,$strain,  undef) = split /\t/,$_;
    $sample .='_31';
    system "cp ../ecolireads/$sample/blat/gene_calls/$strain.csv best_strain/$sample.$strain";

}
close IN;

# this makes :
# step 1) want to make sets like :
# tp1.barcode1 {a,b,c} 	  (indiv 1)
# tp1.barcode2 {a,b,c}	  (indiv 1)
# tp1.barcode3 {a,b,e}	  (indiv 1)
# tp1.barcode3 {b,c,d}	  (indiv 2)
# tp1.barcode3 {b,c,e}	  (indiv 2)
# tp1.barcode3 {b,c,f}	  (indiv 3)

use strict;
use warnings;

my %barcode_to_ECO_genes;

my @files = `ls ~/e_reich/tp1/reads/*_31/blat/gene_calls/all_strains.ECO_GENES_hit`;
foreach my $file (@files){
    chomp $file;
    open IN, $file or die $!;

    my (undef,undef,undef,undef,undef,undef,$barcode,undef,undef) = split /\//,$file;
    $barcode =~ s/_31//;

    while (<IN>){
	chomp $_;
	$barcode_to_ECO_genes{$barcode}{$_}=1
    }
    close IN;
}


foreach my $barcode (keys %barcode_to_ECO_genes){
    open OUT, ">derived_data/ECO_GENE_tp1_HOST.$barcode";
    print OUT join "\n",keys %{$barcode_to_ECO_genes{$barcode}};
    close OUT;
}

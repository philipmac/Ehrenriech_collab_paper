# using Ian's file sample_indiv_type.csv
# and my call of the neares strain
# create an output file : top_picks_merged_with_Ian_work

use warnings;
use strict;

open IN, "derived_data/sample_indiv_type.csv" or die $!;
my %sampleToHostAndType;
while (<IN>){
    chomp $_;
    next if $_ =~ /Barcode|^\s?$/g;

    my ($barcode,$host,$straintype) = split /\t/,$_;
    $sampleToHostAndType{$barcode}{HOST}=$host;
    $sampleToHostAndType{$barcode}{TYPE}=$straintype;
}

my @contigs = `ls gene_counts/*31`;

my %sortableHash;		# this just means I can sort on whatever...
foreach my $contig (@contigs){
    chomp $contig;

    my ($commonGenes,$strain)=split /\s/, `head -1 $contig`;
    $contig =~ s/_31|gene_counts|\///g;

#    print "=$contig=" if !defined $sampleToHostAndType{$contig}; # =CGAAAT=  => is Ian missing a line?
    $sortableHash{$contig}{STRAIN}=$strain;
    $sortableHash{$contig}{LINE}= join "\t",($contig, $strain, $commonGenes, $sampleToHostAndType{$contig}{TYPE}, $sampleToHostAndType{$contig}{HOST},"\n");    
}

open OUT, ">derived_data/top_picks_merged_with_Ian_work" or die $!;
print OUT join "\t",qw/barcode E_coli_strain_called num_genes_common type host/;
print OUT "\n";
foreach my $contigSet (sort {$sortableHash{$a}{STRAIN} cmp $sortableHash{$b}{STRAIN} } keys %sortableHash){
    print OUT $sortableHash{$contigSet}{LINE};
}
close OUT;

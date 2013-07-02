# this might be no longer needed...
use warnings;
use strict;

my @files = `ls ../ecolireads/*_31/blat/gene_calls/Escherichia_coli*.csv`;
system "rm gene_counts/*";	# important, I am catting output

foreach my $file (@files){

    # prep
    chomp $file;
    my (undef, undef, $contigSet,undef, undef, $strain)=split /\//,$file;
    $strain =~ s/\.csv//;

    open IN, $file or die $!;
    my %p_to_gene;
    while (<IN>){
	chomp;
	my ($p,$gene)=split ',';
	push @{$p_to_gene{$p}},$gene;
    }
    close IN;
    
    # loop through the plasmids, sum up the gene content of each
    my $plasmids = '';
    my $totNumGenes=0;
    foreach (keys %p_to_gene){
	$totNumGenes += scalar @{$p_to_gene{$_}};
	$plasmids .= $_.' ('.scalar @{$p_to_gene{$_}}.") ";
    }

    # note catting output
    open OUT, ">>gene_counts/$contigSet".'_gene_counts';
    print OUT join "\t", ($totNumGenes,$strain,$plasmids,"\n");
    close OUT;
}

# this converts everything in ../reads to fasta.

use warnings;
use strict;

my @fastqs = `ls ../reads/*/merged_*.fq`;
foreach my $fq (@fastqs){
    chomp $fq;
    my $out = $fq;
    $out =~ s/fq/fa/;
    system "fastq_to_fasta -n -i $fq -o $out"
}

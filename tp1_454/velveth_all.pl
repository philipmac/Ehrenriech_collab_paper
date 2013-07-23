# run the first velvet binary (velveth) over all samples;

use strict;
use warnings;

my @samples = `ls ~/e_reich/tp1_454/*.fasta`;

my $k = 57;
my $repl = '_k_'.$k;

foreach my $sample (@samples){
    chomp $sample;
    my $outDir = $sample;
    $outDir =~ s/\.fasta/$repl/;
    system "mkdir $outDir" unless (-d $outDir);
    system "~/packages/velvet_1.2.10/velveth $outDir $k -shortPaired $sample";# unless (-e "$outDir/Log");
}

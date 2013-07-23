# run the first velvet binary (velveth) over all samples;

use strict;
use warnings;


my @samples = `ls ~/e_reich/tp1_hi_covg/reads/*/merged_*_ds_4.fa`;
my $covg = 30;
my $k = 31;
my $repl = 'k_'.$k.'_covg_'.$covg;
foreach my $sample (@samples){
    chomp $sample;

    my $outDir = $sample;
    $outDir =~ s/merged_//;
    $outDir =~ s/\.fa/$repl/;
    system "mkdir $outDir" unless (-d $outDir);
    system "~/packages/velvet_1.2.10/velveth $outDir $k -shortPaired $sample" unless (-e "$outDir/Log");
}

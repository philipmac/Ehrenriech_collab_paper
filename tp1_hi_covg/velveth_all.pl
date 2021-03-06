# run the first velvet binary (velveth) over all samples;

use strict;
use warnings;


my @samples = `ls ~/e_reich/tp1_hi_covg/reads/*/merged_*.fa`;
my $covg = 100;
my $k = 57;
my $repl = 'k_'.$k.'_covg_'.$covg;
foreach my $sample (@samples){
    chomp $sample;
    next if $sample =~ /_ds_/; 	# don't want to touch the downsampled stuff
    my $outDir = $sample;
    $outDir =~ s/merged_//;
    $outDir =~ s/\.fa/$repl/;
    system "mkdir $outDir" unless (-d $outDir);
    system "~/packages/velvet_1.2.10/velveth $outDir $k -shortPaired $sample";# unless (-e "$outDir/Log");
}

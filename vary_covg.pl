use strict;
use warnings;

my @files = `ls ../L37/*/contigs.fa`;

foreach my $file (@files){
    chomp $file;
    my $outDir = $file;
    $outDir =~ s/contigs\.fa//;


    print $file;
    foreach my $covg (100){
    	system "/home/philip/code/velvet/velvetg $outDir -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
    }
    last;
}

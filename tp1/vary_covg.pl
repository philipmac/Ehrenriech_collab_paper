use strict;
use warnings;

my $base = '../scratch/AAAAGG_k_31';

my $max_covg = 100;
my $covg = 20;
my $step = 10;

while ($covg <= $max_covg){
    my $outDir = $base."_asmbl_$covg";
    #print $outDir,"\n";
    system "mkdir $outDir" unless (-d $outDir);
    system "cp $base/Roadmaps $outDir/Roadmaps";
    system "cp $base/Sequences $outDir/Sequences";
    system "/home/philip/packages/velvet_1.2.10/velvetg $outDir -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
    $covg += $step;
}

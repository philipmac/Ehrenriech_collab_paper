# run the second velvet binary (velvetg) over all samples two times since something happens the 2nd time;

use strict;
use warnings;

my @samples = `ls ~/e_reich/tp1_454/*/Log`;

my $covg = 100;
foreach my $sample (@samples){
    chomp $sample;
    $sample =~ s/\/Log//;
    next if (-e "$sample/contigs.fa");
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 "; # -cov_cutoff 2 -exp_cov $covg
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 "; # -cov_cutoff 2 -exp_cov $covg
}

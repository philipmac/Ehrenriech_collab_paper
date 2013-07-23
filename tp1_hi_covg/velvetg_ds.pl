use strict;
use warnings;



my @samples = `ls ~/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/Log`;

my $covg = 30;
#my $step = 10;
foreach my $sample (@samples){
    chomp $sample;
    $sample =~ s/\/Log//;
    next if (-e "$sample/contigs.fa");
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
}

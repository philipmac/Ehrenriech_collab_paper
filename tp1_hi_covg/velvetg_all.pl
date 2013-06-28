use strict;
use warnings;


my @samples = `ls ../reads/*/*_ds_4k_31_covg_30/Log`;

my $covg = 30;
#my $step = 10;
foreach my $sample (@samples){
    chomp $sample;
    $sample =~ s/\/Log//;
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
}

use strict;
use warnings;



my @samples = `ls ~/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/Log`;

my $covg = 100;
foreach my $sample (@samples){
    chomp $sample;
    next if $sample =~ /_ds_/; 	# don't want to touch the downsampled stuff
    $sample =~ s/\/Log//;
    next if (-e "$sample/contigs.fa");
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
    system "~/packages/velvet_1.2.10/velvetg $sample -ins_length 300 -cov_cutoff 2 -exp_cov $covg";
}

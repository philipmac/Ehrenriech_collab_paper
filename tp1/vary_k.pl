use strict;
use warnings;

my @files = `ls ../scratch/*.fa`;

foreach my $file (@files){
    chomp $file;
    
    #my @f = split /\//,$file;

    foreach my $k (29,31,33,35,37){

	my $outDir = $file;
	$outDir =~ s/\.fa/_k_$k/;
	system "mkdir $outDir" unless (-d $outDir);

	system "~/packages/velvet_1.2.10/velveth $outDir $k -shortPaired $file";
	system "~/packages/velvet_1.2.10/velvetg $outDir -ins_length 300 -cov_cutoff 2 -exp_cov 40";

    }

}

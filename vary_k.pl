use strict;
use warnings;


my @files = `ls ../L37/*per*fa`;
foreach my $file (@files){
    chomp $file;
    
    my @f = split /\//,$file;

    foreach my $k (29,31,33,35,37){
	my $le = $f[2];
	$le =~ s/\.fa/_$k/;
	my $outDir = join '/',($f[0],$f[1],$le);
    
	print $outDir,"\n";
	system "/home/philip/code/velvet/velveth $outDir $k -shortPaired $file";
	system "/home/philip/code/velvet/velvetg $outDir -ins_length 300 -cov_cutoff 2 -exp_cov 40";

    }

}

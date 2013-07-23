# this just down samples the hi coverage data to look like the low coverage data
# allowing us to compare like with like on assemblies. 

use strict;
use warnings;

system ("rm ../reads/*/*ds*fa") if ($ARGV[0] && $ARGV[0] =~ /clean/);

my @filesToDS=`ls ~/e_reich/tp1_hi_covg/reads/*/*fa`;
my $mod = 4;


foreach my $fa (@filesToDS){
    next if $fa =~ /_ds_/;
    chomp $fa;
    open IN, "<", $fa or die $!;
    
    my $outFile = $fa;
    $outFile =~ s/\.fa/_ds_$mod\.fa/;
    next if (-e $outFile);
    open OUT, ">", $outFile or die $!;

    my $ok=0;
    my $counter=0;
    while (<IN>){
	if ($_ =~ /^>/){ $counter++ }
	
	if (($counter%$mod)==0){ $ok=1 }
	else { $ok = 0 }

	next unless $ok;
	print OUT $_;
    }
    close IN;
    close OUT;
	

}

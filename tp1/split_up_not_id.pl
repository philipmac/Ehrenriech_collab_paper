use warnings;
use strict;

my @files = `ls /home/philip/e_reich_tp1/perl/tags/non_id/imp*`;
foreach my $file (@files){
    open IN, $file or die;


    my $nf = 0;
    while(<IN>){
	if ($_ =~ /--NOT IDENTICAL--/){
	    $nf = 1;
	    close OUT;
	    next;
	}
	if ($_ =~ /^>/){

	    my @on = split /\s+/,$_;
	    my $outNam = $on[0];
	    $outNam =~ s/:|>//g;
	    $outNam =~ s/\||-/_/g;
	    if ($nf){
		open OUT, ">/home/philip/e_reich_tp1/perl/tags/non_id/comp/$outNam" or die $!;
	    }
	    $nf=0;
	}
	print OUT $_;
    }
    close IN;
}

use strict;
use warnings;

my @files = `ls tags/dups_*`;
foreach my $file (@files){
    chomp $file;
    open (IN, $file)or die $!;
    my $str = $file;
    $str =~ s/tags\///;
    my $out = "tags/non_id/imperfect.$str";
    open (OUT, ">$out") or die $!;
    my $printing = 0;
    while (<IN>){

	if ($_ =~ /^--/){
	    if  ($_ =~ /^--NOT IDENTICAL--/){
		$printing = 1;
	    }
	    else { 
		$printing = 0;
	    }
	}
	
	print OUT $_ if $printing;
    }
    close IN;
    close OUT;
}

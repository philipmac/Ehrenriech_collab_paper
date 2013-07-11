use warnings;
use strict;

# runs through the psl output of blat, and prunes off the stuff we're not interested in. 
# outputs a csv file.


my @psl_files = `ls ../../tp2/reads/*/k_31_covg_30/blat/*.psl`;

foreach my $file (@psl_files){
    chomp $file;

    open IN, $file or die $!;

    my $outFile = $file;
    $outFile =~ s/\.psl/\.csv/;
    open OUT, ">$outFile" or die $!;

    while (<IN>){
    	next unless $_ =~ /^\d/;
    	my @a = split /\t/,$_;
	my $faHeader = $a[13];
	my @b = split /\|/,$faHeader;
	my $nc_name = $b[$#b-1];
	my $loc = $b[$#b];
	$loc =~ s/://;

	my $geneLen=$a[10];
	foreach ($a[$#a-2],$a[$#a-1]){ # rms trailing commas from some fields where we dont want them
 	    $_=~ s/,$//;
	}
	my @blockSizes = split /,/,$a[$#a-2];
	my $lens = join ',',@blockSizes;

	my @starts = split /,/,$a[$#a-1];
	my $startAsString = join ',',@starts;
	my $strand = $a[8];
	print OUT join "\t",($nc_name,$loc,$geneLen,$lens,$startAsString,$strand);
	print OUT "\n";
	
    }
    close IN;
    close OUT;

}

print "blat parse done...\n";

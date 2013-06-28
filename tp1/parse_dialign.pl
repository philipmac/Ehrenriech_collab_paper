use warnings;
use strict;
my @files = `ls tags/non_id/comp/*ali`;

# Numbers below the alignment reflects the degree of local similarity 
# among sequences. More precisely: They represent the sum of `weights' 
# of fragments connecting residues at the respective position.

# These numbers are normalized such that regions of maximum similarity 
# always get a score of 9 - no matter how strong this maximum simliarity 
# is. 


my $maxNumZeros = 10;
my $str;
foreach (0..$maxNumZeros){
    $str.=0;
}

open BM, ">bm";
my %geneToAlignStat;
foreach my $file (@files){
    chomp $file;
    my $matchOK=1;
    my $geneName = $file;
    $geneName =~ s/.*\/|\.ali//g;
    open IN, $file or die $!;    
    while (<IN>){
	chomp $_;
	$_ =~ s/\s+//g;
	next unless $_ =~ /^\d*$/;	
	$matchOK = 0 if $_ =~ /$str/;
    }
    close IN;
    print BM $file,"\n" if !$matchOK;

    print "$geneName seen twice\n" if exists $geneToAlignStat{$geneName};
    $geneToAlignStat{$geneName}=$matchOK;
}

open OUT, ">GENE_ALIGNMENT_GOOD" or die $!;
foreach (keys %geneToAlignStat){
    print OUT join "\t", ($_,$geneToAlignStat{$_},"\n");
}
close OUT;

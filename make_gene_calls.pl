# now I'm going to run through the csv files (pruned versions of blat out) and make a call if the gene is present in the contig or not.

use warnings;
use strict;

my $minHitLen = 90;


foreach my $file (`ls ~/e_reich_tp1/ecolireads/*_31/blat/summary/Escherichia_coli*`){ # (gene geneLen hitLens hitLocationOnGene strand)

    my (%startHitButTooShort, %endHitButTooShort, %isLongHit);
    my %genesHit;
    my %allGenes;

    chomp $file;
    open IN, $file or die $!;

    my $geneCallDir = $file;
    $geneCallDir =~ s/blat.*//;
    $geneCallDir .= 'blat/gene_calls'; # each sample will have its own gene calls dir
    system "mkdir $geneCallDir" unless -d $geneCallDir;

    my $outFile = $file;
    $outFile =~ s/summary/gene_calls/; 
    $outFile .='.csv';
    # my $outDir = $outFile;
    # $outDir =~ s/\/Esch_.*//;

    # system "mkdir $outDir" unless -d $outDir;

    while (<IN>){
	chomp $_;
	my ($gene,$geneLen,$lens,$starts,$strand) = split /\t/;

	push @{$allGenes{$gene}},$_;
	my @lens = split /,/,$lens;
	my @starts = split /,/,$starts;

	# define a gene being present if can find :
	# ~len of gene found or (if len is less than 90)
	# initial $minHitLen or 
	# ultimate $minHitLen bp


	while (my ($index, $start) = each @starts) {
	    my $end = $start + $lens[$index];

	    if ($lens[$index] < $minHitLen){  # len is less than 90
		$startHitButTooShort{$gene}=1 if ($start =~ /0|1/);
		
		$endHitButTooShort{$gene}=1 if ($end == $geneLen || ($end == $geneLen-1));
		next;
	    }

	    $genesHit{$gene}=1 if ($start =~ /0|1/); # if elt is at start 
	    $genesHit{$gene}=1 if ($end == $geneLen || ($end == $geneLen-1)); # last elt
	}

	foreach (@lens){
	    $genesHit{$gene}=1 if ($_ == $geneLen || $_+1 == $geneLen);
	    $isLongHit{$gene}=1 if $_ > $minHitLen;
	}

	#$genesHit{$gene}=1 if $isLongHit{$gene} && ($endHitButTooShort{$gene} || $startHitButTooShort{$gene});
#	print $gene,"\n" if ($isLongHit{$gene} && ($endHitButTooShort{$gene} || $startHitButTooShort{$gene}));
    }
    close IN;
    # print "$outFile\n";
    # exit;
    open OUT, ">$outFile" or die $!;
    print OUT join "\n",(keys %genesHit);
    close OUT;
#    print $outFile,"\n";
    #last;
}

# print "all: ",scalar (keys %allGenes), "\n";
# print "good:",scalar (keys %genesHit), "\n";

# open BAD, ">bad.csv" or die$!;
# foreach (keys %allGenes){
#     print BAD join "\n",@{$allGenes{$_}},"\n" unless $genesHit{$_};
# }
# close BAD;
	
    


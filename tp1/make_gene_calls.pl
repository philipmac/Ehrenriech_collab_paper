# now I'm going to run through the csv files (pruned versions of blat out) and make a call if the gene is present in the contig or not.

use warnings;
use strict;
use Eco;

my %geneToLocName = %{make_plasmid_loc_to_locus()};

foreach my $file (`ls ~/e_reich/tp1/reads/*_31/blat/Escherichia_coli*.csv`){ # (gene geneLen hitLens hitLocationOnGene strand)
    my (%startHitButTooShort, %endHitButTooShort, %isLongHit);
    my %genesHit;

    chomp $file;
    open IN, $file or die $!;

    my $geneCallDir = $file;
    $geneCallDir =~ s/blat.*//;
    $geneCallDir .= 'blat/gene_calls'; # each sample will have its own gene calls dir
    system "mkdir $geneCallDir" unless -d $geneCallDir;

    my $coli_name = get_coli_name_from_file($file);
    my $outFile = $geneCallDir.'/'.$coli_name.'.csv';

    while (<IN>){
	chomp $_;
	my ($plasmid,$geneLoc,$geneLen,$lens,$starts,$strand) = split /\t/;
	$plasmid =~ s/\.\d+//;
	my $gene = "$plasmid,$geneLoc";

#	push @{$allGenes{$gene}},$_; # this is in case you want to do diffs and things with *every* gene.

	my @lens = split /,/,$lens;
	my @starts = split /,/,$starts;

	# define a gene being present if can find :
	# ~len of gene found or (if len is less than 90)
	# initial $minHitLen or 
	# ultimate $minHitLen bp

	while (my ($index, $start) = each @starts) {
	    my $end = $start + $lens[$index];

	    if ($lens[$index] < $Eco::minHitLen){  # len is less than 90
		$startHitButTooShort{$gene}=1 if ($start =~ /0|1/);		
		$endHitButTooShort{$gene}=1 if ($end == $geneLen || ($end == $geneLen-1));
	    }
	    else{
		$genesHit{$gene}=1 if ($start =~ /0|1/); # if elt is at start 
		$genesHit{$gene}=1 if ($end == $geneLen || ($end == $geneLen-1)); # last elt
	    }
	}

	foreach (@lens){
	    $genesHit{$gene}=1 if ($_ == $geneLen || $_+1 == $geneLen);
	    $isLongHit{$gene}=1 if $_ > $Eco::minHitLen;
	}

	#$genesHit{$gene}=1 if $isLongHit{$gene} && ($endHitButTooShort{$gene} || $startHitButTooShort{$gene});
#	print $gene,"\n" if ($isLongHit{$gene} && ($endHitButTooShort{$gene} || $startHitButTooShort{$gene}));
    }
    close IN;

    # dump...
    open OUT, ">$outFile" or die $!;
    foreach (keys %genesHit){
	my $loc='';
	$loc = $geneToLocName{$_} if defined $geneToLocName{$_};
	print OUT join "\t", ($_,$loc,"\n");
    }
    close OUT;
    #print $outFile,"\n";
}

# print "all: ",scalar (keys %allGenes), "\n";
# print "good:",scalar (keys %genesHit), "\n";

# open BAD, ">bad.csv" or die$!;
# foreach (keys %allGenes){
#     print BAD join "\n",@{$allGenes{$_}},"\n" unless $genesHit{$_};
# }
# close BAD;
	
    


# now I'm going to run through the csv files (pruned versions of blat out) and make a call if the gene is present in the contig or not.

use warnings;
use strict;

my $minHitLen = 90;

my %geneToLocName;
open IN, "map_withEcoGene" or die $!;
while (<IN>){
    #Escherichia_coli_042_uid161985NC_017626336-2798LOCUSTAG: EC042_0001LOCUS: thrASYNS: ECOGENE: EG10998GENEID:
    my (undef,$plsmd,$location,undef,$locus,$syns,$ecogene,undef)=split /\t/,$_;
    $locus =~ s/LOCUS:|\s+//g;
    $syns =~ s/SYNS:|\s+//g;
    
    $geneToLocName{"$plsmd,$location"}=$locus;
    if ($syns ne ''){
	$geneToLocName{"$plsmd,$location"}.=','.$syns;
    }    
}
close IN;

# foreach (keys %geneToLocName){
#     print "$_, $geneToLocName{$_},\n";
# }
# exit;

foreach my $file (`ls ~/e_reich_tp1/ecolireads/*_31/blat/summary/Escherichia_coli*`){ # (gene geneLen hitLens hitLocationOnGene strand)
    my (%startHitButTooShort, %endHitButTooShort, %isLongHit);
    my %genesHit;
#    my %allGenes;

    chomp $file;
    open IN, $file or die $!;

    my $geneCallDir = $file;
    $geneCallDir =~ s/blat.*//;
    $geneCallDir .= 'blat/gene_calls'; # each sample will have its own gene calls dir
    system "mkdir $geneCallDir" unless -d $geneCallDir;

    my $outFile = $file;
    $outFile =~ s/summary/gene_calls/; 
    $outFile .='.csv';

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

	    if ($lens[$index] < $minHitLen){  # len is less than 90
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
	    $isLongHit{$gene}=1 if $_ > $minHitLen;
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
	
    


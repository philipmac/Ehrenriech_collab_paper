# sanity check on our velvet assemblies. 
# this parses the blat alignment of 454 indesdown sampled reads, 
# checks are : 

# 1) the query match seq + slop ~= totalLen of query  AND the matchLens are about the same size
# 2) the start of the match on the query is about the start of the query AND the end of the match is at the end of the contig
# 3) the start of the match on the contig is about the start of the contig AND 454 (query) end is past the end of contig


use strict;
use warnings;
use Statistics::Basic qw(:all);

my @psls = `ls ~/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/contigs_vrs_454.psl`;

my $slop = 9;
#my $max_gap = 10;
my $min_align_len = 50;
my $min_pc_match = 90;
my @aves;

my @linesUsed;			# going to push on anything from the blat file I use here to get stats for paper.

foreach my $psl(@psls){
    chomp $psl;

    open IN, $psl or die $!;
    my %fff_ok;
    while (<IN>){
	next unless $_ =~ /^\d/;
	my @l = split/\t/,$_;
	my ($qgap, $tgap) = ($l[5], $l[7]);
#	next if ($qgap > 10 || $tgap > 10);

	my $blockSize = $l[$#l-2];
	$blockSize =~ s/,$//;
	my @blockSizes = split ',', $blockSize;
#	my $skip=1;
	my $totSize=0;
	foreach (@blockSizes){
	    $totSize += $_;
#	    $skip=0 if $_>$min_align_len;
	}
#	next if $skip;
	my ($fff,$qSize,$qStart,$qStop)=@l[9..12];
	my ($tSize,$tStart,$tStop)=@l[14..16];

	my $matchLenOnTarget = $tStop-$tStart; # ie contig
	my $matchLenOnQ = $qStop-$qStart;      # ie 454

	my ($s,$l) = sort {$a <=> $b} ($matchLenOnTarget,$matchLenOnQ);
	my $pc_match = ($s/$l)*100;
	next if $pc_match < $min_pc_match;
	# if the whole thing is in the contig
	# if the qstart is near the start of itself, & it runs out
	# runs off the end of the 454
	if ( ($matchLenOnQ+$slop >= $qSize) && (abs($matchLenOnTarget-$matchLenOnQ)<=$slop)){
	    push @linesUsed,$_;
	    $fff_ok{$fff} = 1;
	}
	     
	elsif ( ($qStart<$slop) && (($tStop+$slop)>=$tSize) ||
		($tStart<=$slop) && (($qStop+$slop)>=$qSize) ){
	    next if ($matchLenOnTarget < $min_align_len);
	    next if ($matchLenOnQ < $min_align_len);
	    push @linesUsed,$_;
	    $fff_ok{$fff} = 1;	    
	}
    }
    close IN;

    my $well = $1 if ($psl =~ /reads\/(\w+)\//);

    my $totalNumberfffs = `egrep ">" ~/e_reich/tp1_454/$well.fasta | wc -l`;
    chomp $totalNumberfffs;

    my $numOKCtgs = scalar (keys %fff_ok);
    my $pc = ($numOKCtgs/$totalNumberfffs)*100;
    push @aves,$pc;
    print "For $well, $numOKCtgs OK Ctgs out of a total of $totalNumberfffs (";
    printf("%.2f", $pc);
    print "%)\n";
#    last;
}
	
my $v1  = vector(@aves);
my $std = stddev($v1);
print 'Mean :'.mean($v1)."\n"; 
print "Stddev : $std\n";

open OUT, ">LINES_USED" or die $!;
print OUT join "\n", @linesUsed;
close OUT;



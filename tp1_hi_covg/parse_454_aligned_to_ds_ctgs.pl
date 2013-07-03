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
my @aves;

foreach my $psl(@psls){
    chomp $psl;

    open IN, $psl or die $!;
    my %fff_ok;
    while (<IN>){
	next unless $_ =~ /^\d/;
	my @l = split/\t/,$_;
	my ($fff,$qSize,$qStart,$qStop)=@l[9..12];
	my ($tSize,$tStart,$tStop)=@l[14..16];
	my $matchLenOnTarget = $tStop-$tStart;
	my $matchLenOnQ = $qStop-$qStart;
	$fff_ok{$fff} = 1 if ($matchLenOnQ+$slop >= $qSize) && (abs($matchLenOnTarget-$matchLenOnQ)<=$slop); # if the whole thing is in the contig
	$fff_ok{$fff} = 1 if (($qStart<$slop) && (($tStop+$slop)>=$tSize) ); # if the qstart is near the start of itself, & it runs out
	$fff_ok{$fff} = 1 if (($tStart<=$slop) && (($qStop+$slop)>=$qSize) ); # runs off the end of the 454
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
}
	
my $v1  = vector(@aves);
my $std = stddev($v1);
print 'Mean :'.mean($v1)."\n"; 
print "Stddev : $std\n";

exit;


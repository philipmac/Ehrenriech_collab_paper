#this just pulls stuff that's useful ie hit name & E valu
# We want to make sure we do not have a case where a spacer has an OK existing CRISPR hit, and a very good other hit.

use strict;
use warnings;
use Eco;

#system "rm data/blast_output/*.summary*";

my %head_to_seq = %{load_FA('../crispr/data/spacers_uniq.fa')}; # this loads up the original spacers, I need this because some things have zero hits, so I want to make sure I know what I went looking for.

my %query_to_e_val = %{do_parse('../crispr/data/blast_output/spacers_uniq.blast.txt')}; # this looks through the BLAST summary, and pulls out intersting things

my %sample_has_good_coli_crispr;
my %sample_has_poor_coli_crispr;
my %sample_has_other_crispr;
my %sample_has_no_crispr;

my $max=0;
foreach my $sample (sort keys %query_to_e_val){
    my (undef,$sampleNo)= split /_/,$sample;

    $max=$sampleNo if $max<$sampleNo;

    foreach (keys %{$query_to_e_val{$sample}}){
	next if $sample_has_good_coli_crispr{$sample};

	if ( $_ =~ /crispr/i ){
	    if ($_ =~ /coli/i) {
		if ($query_to_e_val{$sample}->{$_} =~ /e/)  { # this means that anything that has a value of >0.001 is denoted as "poor" (below)
		    $sample_has_good_coli_crispr{$sample}=1;
		}
		else{
		    $sample_has_poor_coli_crispr{$sample}=1;
		}
	    }		
	    else{
		$sample_has_other_crispr{$sample}=1;
	    }
	}
    }

    unless($sample_has_good_coli_crispr{$sample} || $sample_has_poor_coli_crispr{$sample} || $sample_has_other_crispr{$sample}){
	$sample_has_no_crispr{$sample}=1
    }
}

# don't care about things that have good or ok existing coli crisprs, (<- unless there is something else v good there).
my $col_head = join "\t", ('int','Description','e-value','spacer');
$col_head .="\n";

open COLI_CRISPRS, ">data/coli_crisprs.summary" or die $!;
print COLI_CRISPRS $col_head;

open OTHER_CRISPR, ">data/other_crispr.summary" or die $!;
print OTHER_CRISPR $col_head;

open NO_CRISPR, ">data/no_crispr.summary" or die $!;
print NO_CRISPR $col_head;

open NOTHING, ">data/nothing_crispr.summary" or die $!;
print NOTHING $col_head;

foreach my $sample (1..$max){

    my $name = 'spacer_'.$sample;
    die "no spacer sequence for $sample\n" if !defined $head_to_seq{">$name"};

    my @lines;
    foreach (keys %{$query_to_e_val{$name}}){
	my $line = join "\t",( $name,$_ ,$query_to_e_val{$name}->{$_}, $head_to_seq{">$name"});
	push @lines,$line;
    }
    push @lines,"\n";

    if($sample_has_good_coli_crispr{$name} || $sample_has_poor_coli_crispr{$name}){
	print COLI_CRISPRS join "\n", @lines
    }
    elsif($sample_has_other_crispr{$name}){
	print OTHER_CRISPR join "\n", @lines
    }
    elsif ($sample_has_no_crispr{$name}){
	print NO_CRISPR join "\n", @lines
    }
    else{
	print NOTHING join "\t",($name,"Nothing", $head_to_seq{">$name"},"\n")
    }
}

close NO_CRISPR;
close OTHER_CRISPR;
close COLI_CRISPRS;
close NOTHING;



# >gb|JF495910.1| Escherichia coli strain R209 CRISPR1 repeat region
# Length=1065

#  Score = 55.4 bits (60),  Expect = 3e-06
#  Identities = 30/30 (100%), Gaps = 0/30 (0%)
#  Strand=Plus/Plus

# Query  1    GCTGGTGGCGCGGGCAAACGGAACAATCCC  30
#             ||||||||||||||||||||||||||||||
# Sbjct  395  GCTGGTGGCGCGGGCAAACGGAACAATCCC  424

sub do_parse{
    my $file = $_[0];

    open IN, $file or die $!;
    my $started=0;
    my $head;
    my %ret;
    my $qn; 
    while (<IN>){
	chomp;	
	if ($_ =~ /Query= (.*)/){
	    $qn = $1 ;
	    die "I've seen $qn before\n" if exists $ret{$qn};
	}
	if ($_ =~ /^>(.*)/){
	    my @a = split /\|/,$1;
	    $head = $a[$#a];
	    $head =~ s/^\s//;
	    $started = 1;
	}

	next unless $started;
	
	if ($_ =~ /Expect = (.*)/){
	    my $expect = $1;
	    $expect =~ s/\s+//g;
  	    next if (($expect !~ /e/) && ($expect > 0.1)); # ditch everything that is not OK e value
	    $ret{$qn}{$head}=$expect;
	}
    }
    die "Something went wrong with loading $file\n" if scalar keys %ret == 0;
    return \%ret;
}

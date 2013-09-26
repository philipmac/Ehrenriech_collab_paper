#this just pulls stuff that's useful ie hit name & E valu
# We want to make sure we do not have a case where a spacer has an OK existing CRISPR hit, and a very good other hit.

use strict;
use warnings;

# my $s = '84.tp_1';
# my @as = split /\./,$s;
# print @as;
# exit;
my @tps = `ls data/blast_output/*.out`;
system "rm data/blast_output/*.summary*";

foreach my $file (@tps){

    chomp $file;
    my $tp = $1 if $file =~ /\/(\w+)\.out/;

    die "no tp for $file" if !$tp;

    my %head_to_seq = %{load_seq([`ls spacers_uniq.$tp.fa`])}; # this loads up the original spacers

    my %query_to_e_val = %{do_parse($file)}; # this looks through the BLAST summary, and pulls out intersting things
    
    my %sample_has_good_coli_crispr;
    my %sample_has_poor_coli_crispr;
    my %sample_has_other_crispr;
    my %sample_has_no_crispr;

    my $max=0;
    foreach my $sample ( keys %query_to_e_val){
	my ($sampleNo,$tp)= split /\./,$sample;

	$max=$sampleNo if $max<$sampleNo;

	foreach (keys %{$query_to_e_val{$sample}}){

	    if ( $_ =~ /crispr/i ){
		if ($_ =~ /coli/i) {
		    if ($query_to_e_val{$sample}->{$_} =~ /e/)  {
			$sample_has_good_coli_crispr{$sampleNo}=1;
		    }
		    else{
			$sample_has_poor_coli_crispr{$sampleNo}=1;
		    }
		}		
		else{
		    $sample_has_other_crispr{$sampleNo}=1;
		}
	    }
	}

	unless($sample_has_good_coli_crispr{$sampleNo} || $sample_has_poor_coli_crispr{$sampleNo} || $sample_has_other_crispr{$sampleNo}){
	    $sample_has_no_crispr{$sampleNo}=1
	}
    }

    print "Total number of uniq spacers in $tp is: $max\n";

    # don't care about things that have good or ok existing coli crisprs, (<- unless there is something else v good there).
    my $coli_crisprs = $file;
    $coli_crisprs =~ s/\.out/\.summary_coli_crispr\.csv/;
    my $col_head = join "\t", ('int','Description','e-value','spacer',"\n");
    open COLI_CRISPRS, ">$coli_crisprs" or die $!;
    print COLI_CRISPRS $col_head;

    my $other_crispr = $file;
    $other_crispr =~ s/\.out/\.summary_other_crispr\.csv/;    
    open OTHER_CRISPR, ">$other_crispr" or die $!;
    print OTHER_CRISPR $col_head;

    my $no_crispr = $file;
    $no_crispr =~ s/\.out/\.summary_no_crispr\.csv/;
    open NO_CRISPR, ">$no_crispr" or die $!;
    print NO_CRISPR $col_head;

    my $nothing = $file;
    $nothing =~ s/\.out/\.summary_nothing\.csv/;
    open NOTHING, ">$nothing" or die $!;
    print NOTHING $col_head;
    
    foreach my $sample (1..$max){

	die "no spacer sequence for $sample , $file, $tp\n" if !defined $head_to_seq{"$sample.$tp"};

	my @lines;
	foreach (keys %{$query_to_e_val{"$sample.$tp"}}){
	    my $line = join "\t",( $sample,$_ ,$query_to_e_val{"$sample.$tp"}->{$_}, $head_to_seq{"$sample.$tp"});
	    push @lines,$line;
	}
	push @lines,"\n";

	if($sample_has_good_coli_crispr{$sample} || $sample_has_poor_coli_crispr{$sample}){
	    print COLI_CRISPRS join "\n", @lines
	}
	elsif($sample_has_other_crispr{$sample}){
	    print OTHER_CRISPR join "\n", @lines
	}
	elsif ($sample_has_no_crispr{$sample}){
	    print NO_CRISPR join "\n", @lines
	}
	else{
	    print NOTHING join "\t",($sample,"Nothing", $head_to_seq{"$sample.$tp"},"\n")
	}
    }

    close NO_CRISPR;
    close OTHER_CRISPR;
    close COLI_CRISPRS;
    close NOTHING;
}


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

sub load_seq{
    my @files = @{$_[0]};
    my %head_to_seq;
    foreach my $file (@files){
        open IN, $file or die $!;
        my $lh;
        
        while (<IN>){
            chomp $_;
            next if $_ =~ /^\s*$/;
            if ($_ =~ s/^>//){
                $lh = $_;
            }
            else {
                $head_to_seq{$lh}=$_;
            }
        }
        close IN;
    }
    return \%head_to_seq;
}

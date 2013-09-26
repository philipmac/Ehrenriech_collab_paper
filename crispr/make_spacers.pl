# this scripts converts the simplified "rep_loc" files to spacers
# next script is the make_spacers_uniq.pl

use strict;
use warnings;

system "rm /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/spacers.fa";
system "rm /home/philip/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/bowtie_index/spacers.fa";
system "rm /home/philip/e_reich/tp1_454/*bowtie_index/spacers.fa";
system "rm /home/philip/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/spacers.fa";
system "rm /home/philip/e_reich/tp1/reads/*_31/bowtie_index/spacers.fa";

my @repeatFiles2 = `ls /home/philip/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/rep_locs.out`;
my @repeatFiles1 = `ls /home/philip/e_reich/tp1/reads/*/bowtie_index/rep_locs.out`;
my @reps_454 = `ls /home/philip/e_reich/tp1_454/*bowtie_index/rep_locs.out`;
my @reps1_hi_covg_ds = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/rep_locs.out`;
my @reps1_hi_covg = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_57_covg_100/bowtie_index/rep_locs.out`;

my @reps = (@reps_454, @reps1_hi_covg_ds, @reps1_hi_covg, @repeatFiles1 , @repeatFiles2);
my %ctg_to_repeats = %{load_repeats(\@reps)}; # # @repeatFiles1,

my @contigs1 =  `ls /home/philip/e_reich/tp1/reads/*_31/contigs.fa`;
my @contigs2 = `ls /home/philip/e_reich/tp2/reads/*/k_31_covg_30/contigs.fa`;
my @contigs_454 = `ls /home/philip/e_reich/tp1_454/*.fasta`; # not really contigs
my @contigs_hi_covg_ds = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/contigs.fa`; # down sampled...
my @contigs_hi_covg = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_57_covg_100/contigs.fa`;

my @conts = (@contigs_454,@contigs_hi_covg_ds, @contigs_hi_covg, @contigs2, @contigs1 );
my %contig_seqs = %{load_contig_seqs(\@conts)};

my %spcrs;

my $too_long = 43;
my $too_short = 20;

open TOO_SHORT, ">too_short";
open TOO_LONG, ">too_long";

foreach my $ctg_name (keys %ctg_to_repeats){
    die "no ctg for $ctg_name\n" if !defined $contig_seqs{$ctg_name};
    my $ctg_seq = $contig_seqs{$ctg_name};
    
    my @reps = @{$ctg_to_repeats{$ctg_name}};	    

#    next if scalar @reps < 2;	# < 2 reps, no spacer (may not be true)

    my $spc_start=0;
    my $spcr_num=0;
    my $prev_rep;
    foreach my $repeat (sort { $a->{LOC} <=>$b->{LOC} } @{reps} ){
#	next unless $repeat->{STRAND} eq '-';
	my $rep_end = $repeat->{LOC}+length($repeat->{SEQ});
	next if $repeat->{OLAPS} && !$repeat->{DOM};
	next unless $rep_end;

	my $comp_rep;
	if ($spc_start){

	    $spcr_num++;

	    my $spc_len = $repeat->{LOC} - $spc_start; # ie this rep start - last rep start 
	    my $spacer = substr $ctg_seq, $spc_start, $spc_len;

	    next if $spacer =~ /N/;
	    #$spacer =~ s/N//g;

	    die "no rep seq \n" if !defined $repeat->{SEQ};
	    die "no rep loc \n" if !defined $repeat->{LOC};

	    $comp_rep = substr $ctg_seq, $repeat->{LOC}, length($repeat->{SEQ}); # this is just to see the computed repeat

	    if (length($spacer) > $too_long){
		print TOO_LONG join "\t",(">$ctg_name","spacer:$spcr_num", $prev_rep,$comp_rep, "rep:".$repeat->{SEQ}.'<',"\n");		
		print TOO_LONG $spacer,"\n";
		print TOO_LONG "\n___________ end ___________\n";

	    }
	    elsif (length($spacer) < $too_short){
		print TOO_SHORT join "\t",(">$ctg_name","spacer:$spcr_num", $prev_rep,$comp_rep, "rep:".$repeat->{SEQ}.'<',"\n");		
		print TOO_SHORT $spacer,"\n";
		print TOO_SHORT "\n___________ end ___________\n";
	    }		
	    else{
		my $file= $repeat->{FILE};
		$file =~ s/rep_locs\.out/spacers\.fa/;
		die "nope" if $file eq $repeat->{FILE};
		open OUT, ">>$file" or die $!;
		print OUT join "\t",(">$ctg_name","spacer:$spcr_num",$repeat->{'TP'},"\n"); #  $prev_rep,$comp_rep, 
		print OUT $spacer,"\n";
		close OUT;
	    }
	}
	$spc_start=$rep_end;
	$prev_rep=$comp_rep;
    }
}
close OUT;
close TOO_LONG;



sub load_contig_seqs{

    my %h;
    foreach my $file (@{$_[0]}){
	my $need=0;

	open IN, $file or die $!;
	while (<IN>){
	    chomp;
	    next if $_ =~ /^\s*$/;
	    if ($_ =~ /^>(\w+\.?\w*)/){	    

#		print $_,"\n",$1,"\n";

		if ($ctg_to_repeats{$1}){
		    $need = $1;
		}
		else{
		    $need = 0
		}
	    }
	    elsif($need){
		$h{$need} .=$_;
	    }
	}
	close IN;
    }
    return \%h;
}


sub load_repeats{
    my %reps;
    foreach my $file (@{$_[0]}){
	chomp $file;
	my $bc = $1 if $file =~ /reads\/(\w+)\//;
	$bc = $1 if $file =~ /tp1_454\/(\w+)bowtie_index/;

	open IN, $file or die $!;

	while (<IN>){
	    # cointig name                      offset seq                        olap? tie breaker! strand timepoint
	    # NODE_9909_length_60_cov_48.633335 0  CGGTTTATCCCCGCTGACGCGGGGAACAC   0   0  + tp1_454
	    # NODE_9909_length_60_cov_48.633335 1  GGTTTATCCCCGCTGGCGCGGGGAACAC    0   1  + tp1_454
	    chomp;
	    my ($ctg_name,$loc,$seq,$is_olap,$tb,$strand,$tp) = split /\t/,$_;

	    # print $file,":",$_,"\n" if $ctg_name eq 'GCGGTTTATCCCCGCTGGCGCGGGGAACTC'; #name eq 'NODE_741_length_58_cov_9.758620';
	    my %r;
	    $r{FILE}=$file;
	    $r{TP}=$tp;
	    $r{BC}=$bc;
	    $r{SEQ}=$seq;
	    $r{OLAPS}=$is_olap;
	    $r{DOM}=$tb;
	    $r{STRAND}=$strand;
	    $r{LOC}=$loc;
	    push @{$reps{$ctg_name}},\%r;
	}

	close IN or warn;	    
    }

    return \%reps;
}




# CGGTTTATCCCCGCTGGCGCGGGGAACACTGAGCGTCGGCGGCTCGCTGGATTTGCGCGGCGGTTTATCCCCGCTGGCGCGGGGAACA
# CGGTTTATCCCCGCTGACGCGGGGAACAC
#  GGTTTATCCCCGCTGGCGCGGGGAACAC

# sub pull_spacers{
    
#     my %reps = $_[0];
#     my %ctgs = %{$_[1]};

    
#     $outFile =~ s/rep_locs\.out/spacers\.fa/;
#     open OUT, ">$outFile" or die $!;

#     foreach (keys %ctgs){
# 	my $contig = $ctgs{$_};
	
# 	my %loc_to_rep;# = %{$ctg_rep_loc_to_rep_seq{$contig->name}}; # locations within this contig

# 	my $last_repeat_end=0;
# 	my $last_repeat;
# 	my $last_spcr_len=0;
# 	my $spcr_count=-1;

# 	foreach my $repeat (sort {$a->start_loc_in_ctg <=>$b->start_loc_in_ctg} @{$contig->repeats} ){
# 	    print "\ncontig seq:",$contig->seq->dna,"\n";
# 	    print "\nseq:",$repeat->seq->dna, "\t","\t str:",$repeat->seq->strand,"\n";

# 	    exit;
# 	    my $comp_rep = substr $contig->seq->dna, $repeat->start_loc_in_ctg, length($repeat->seq->dna); # this is just to see the computed repeat

# 	    print $comp_rep,"\n\n";
# 	}
# 	last;

# 	foreach my $rep_start (sort {$a<=>$b} keys %loc_to_rep){
# 	    $spcr_count++;
# 	    my ($repeat,$strand) = split /_/, $loc_to_rep{$rep_start};
# 	    $repeat = rc($repeat) if $strand eq '-';

# 	    my $this_repeat_end = $rep_start+length($repeat);
	    
# 	    if (!$last_repeat){  # skip over if this is the first repeat
# 		$last_repeat_end = $this_repeat_end;
# 		$last_repeat = $repeat;
# 		next;
# 	    }

# 	    # substr EXPR,OFFSET,LENGTH
# 	    my $comp_rep = substr $contig->seq->get_dna, $rep_start, length($repeat); # this is just to see the computed repeat
# 	    $comp_rep = rc($comp_rep) if $strand eq '-';

# 	    my $this_spacer_start = $last_repeat_end;
# 	    my $this_spacer_end = $rep_start;
# 	    my $spacer_len = $this_spacer_end-$this_spacer_start;
# 	    my $comp_spac= substr $contig->seq->get_dna, $this_spacer_start, $spacer_len; # this is just to see the computed repeat
# 	    $comp_spac =~ s/N//g;
# 	    $comp_spac = rc($comp_spac) if $strand eq '-';
# 	    if (length($comp_spac) > 44){
# 		$comp_spac = substr $comp_spac,0,$last_spcr_len;
# 		$spacer_len = $last_spcr_len;

# 		print OUT '>'.$contig->name." spacer$spcr_count trunc\n";
# 	    }
# 	    else {
# 		print OUT '>'.$contig->name."spacer$spcr_count\n"
# 	    }

# 	    # print OUT "repeat:$comp_rep\n";
	    
# 	    # print OUT $last_repeat_end-length($last_repeat).'..'.$last_repeat_end."\n";
# 	    # print OUT "rep    $repeat\n";

# 	    # print OUT "sp $this_spacer_start, $spacer_len\n";
# 	    print OUT "$comp_spac\n";

# 	    $last_repeat_end = $this_repeat_end;
# 	    $last_repeat = $repeat;
# 	    $last_spcr_len = $spacer_len;
# 	}
#     }

#     close OUT;
# }

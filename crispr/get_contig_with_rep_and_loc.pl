# want to just gather up the bowtie output of the stuff we're interested in and prep it for use. 
# logic, IFF one repeat overlaps another we want to use the most common repeat.
# this file makes the rep_locs files

use strict;
use warnings;

my @aligns1 = `ls /home/philip/e_reich/tp1/reads/*31/bowtie_index/bwt_off_by_three_e_coli.out`;

my @aligns2 = `ls /home/philip/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/bwt_off_by_three_e_coli.out`;

my @align_454 = `ls /home/philip/e_reich/tp1_454/*bowtie_index/bwt_off_by_three_e_coli.out`;
my @aligns1_hi_covg_ds = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/bwt_off_by_three_e_coli.out`;
my @aligns1_hi_covg = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/bowtie_index/bwt_off_by_three_e_coli.out`;


# my @contigs1 =  `ls /home/philip/e_reich/tp1/reads/*_31/contigs.fa`;
# my @contigs2 = `ls /home/philip/e_reich/tp2/reads/*/k_31_covg_30/contigs.fa`;

#my %contig_seqs = %{load_contig_seqs(\@contigs2,\@contigs1 )}; # 


my $too_long_gap = 50;		# this is some number that I;ve decided that a repeat is hiding in the spacer / not a real spacer
my $rep_part_len = 6; 		# this is jus the len of the repeat substr that I'm using to search for the spacer 
my $imaginary_spc_len = 30;	# this is a number that is meant to be less than the real spacer
my $loc_too_far_away = 20; 	# the distance I'll accept the next rep start in.
# NC_013941_2|NC_017656_2 +       NODE_880_length_10360_cov_26.478764     8674    GCC//TGGCGCGGGGAACAC I//IIIIIIIIIIIIII 3 
# 0                       1       2                                       3       4                    5                 6

# NODE_880_length_10360_cov_26.478764 
# +
# 300 GGTTTATCCCCGCTGGCGCGGGGAACAC
# 330 GGTTTATCCCCGCTGGCGCGGGGAACAC
# 360 GGTTTATCCCCGCTGGCGCGGGGAACAC


# print join "\n",keys %contig_seqs;
# exit;

foreach my $align (@aligns1, @aligns2, @align_454, @aligns1_hi_covg_ds, @aligns1_hi_covg){
    my %plus;
    my %minus;
    open IN, $align or die $!;

    while (<IN>){
	chomp;
	my ($rep,$strand,$contig,$offset,$seq,undef,undef,$err)= split /\t/,$_;

	my %rep;
	$rep{REP_NAME}=$rep;
	$rep{SEQ}=$seq;
	$rep{START_LOC}=$offset;

	if ($strand eq '+'){
	    push @{$plus{$contig}},\%rep;	    
	}
	else{
	    push @{$minus{$contig}},\%rep;
	}
    }
    close IN;
    
    foreach my $contig (keys %plus){
	$plus{$contig} = mark_overlaps($plus{$contig});
	$plus{$contig} = mark_dom_rep($plus{$contig});
    }

#    %plus = %{search_repeat_parts(\%plus)};
    print_out($align,\%plus,1);

    foreach my $contig (keys %minus){
    print $align if $contig eq 'AGCTGCCTGTACGGCAGTGAACT';
	$minus{$contig} = mark_overlaps($minus{$contig});
	$minus{$contig} = mark_dom_rep($minus{$contig});
    }
    print_out($align,\%minus,0);
}

sub print_out{
    my ($file, $clobber) = ($_[0], $_[2]); # $ctg_name,@reps

    my $tp = $1 if $file =~ /e_reich\/(\w+)\//;

    my %ctg_to_reps = %{$_[1]};
    $file =~ s/bwt_off_by_three_e_coli/rep_locs/;   

    open OUT, ">$file" or die $!," $file\n" if $clobber;
    open OUT, ">>$file" or die $!," $file\n" if !$clobber;
    
    my $strand;

    if ($clobber) { $strand = '+' }
    else { $strand = '-' }

    foreach my $contig (keys %ctg_to_reps){
	my @a_of_reps = @{$ctg_to_reps{$contig}};
	foreach my $rep (@a_of_reps){
	    # if (defined $rep->{MAYBE_STRT_LOC}){
	    # 	print OUT join "\t",($contig, $rep->{MAYBE_STRT_LOC}, "___", 0, 0, $strand);
	    # 	print OUT "\n";
	    # 	next;
	    # }
	    # contig name, rep start loc, rep seq, if olaps, if dominant, strand

	    print OUT join "\t",($contig, $rep->{START_LOC}, $rep->{SEQ}, $rep->{O_LAP}, $rep->{DOM},$strand, $tp);
	    print OUT "\n";
	}
    }

    close OUT;
}

sub load_contig_seqs{

    my %h;
    foreach my $file (@{$_[0]}){

	my $need=0;
	
	open IN, $file or die $!;
	while (<IN>){
	    chomp;
	    next if $_ =~ /^\s*$/;
	    if ($_ =~ /^>(.*)/){	    
		$need = $1;
	    }
	    elsif($need){
		$h{$need} .=$_;
	    }
	}
	close IN;
    }
    return \%h;
}



sub mark_overlaps{
    # do the spacers overlap each other?
    my @a_of_reps = @{$_[0]};

    my $prev_loc = 0;
    my $prev_rep;

    my @locs = sort {$a->{START_LOC} <=> $b->{START_LOC} } @a_of_reps;
    my $i= 0;
    foreach my $rep (@locs){
	
	if ($prev_rep  && (($prev_rep->{START_LOC} + length($prev_rep->{SEQ}) >= $rep->{START_LOC})) ){
	    $locs[$i]->{O_LAP}=1;
	    $locs[$i-1]->{O_LAP}=1;
	}
	else {
	    $locs[$i]->{O_LAP}=0;
	}
	$i++;
	$prev_rep = $rep
    }
    return \@locs;
}
	
# sub search_repeat_parts{
#     # this is a bit of a hack, I'm saying that if I see some bit of a rep in an area I think a rep
#     # should be, I'm  grabbing it. 
#     my %h = %{$_[0]};
#     foreach my $contig (keys %h){
# 	my @a_of_reps = @{$h{$contig}};

# 	my $prev_rep;
# 	foreach my $rep (@a_of_reps){
# 	    if (!$prev_rep){ 
# 		$prev_rep=$rep;
# 	    }
# 	    elsif ( ($rep->{START_LOC} - $prev_rep->{START_LOC}) > $too_long_gap ){
# 		# see if you can find something that looks like a repeat start...
# 		# substr EXPR,OFFSET,LENGTH
		
# 		# things to look for:
# 		my $rep_start_str = substr $rep->{SEQ},0,$rep_part_len;
# 		my $rep_end_str = substr $rep->{SEQ},-$rep_part_len;

# 		my $whole_ctg=$contig_seqs{$contig};
# 		die "No contig seq for $contig\n" if !$whole_ctg;

# 		# where we left off...
# 		my $offset = $prev_rep->{START_LOC} + length($prev_rep->{SEQ}) + $imaginary_spc_len;
		
# 		my $region_to_look_in = substr $whole_ctg, $offset;
# 		my $loc_strt = index $region_to_look_in, $rep_start_str;

# 		# my $region_to_look_in_stop = substr $whole_ctg, $offset; # just leaving this the same at the moment
# 		# my $loc_strt = index $region_to_look_in, $rep_end_str;

# 		next if $loc_strt == -1;
# 		next if $loc_strt > $loc_too_far_away;
# 		$rep->{MAYBE_STRT_LOC} = $loc_strt +$offset;
# 	    }
# 	}
#     }
#     return \%h;
# }

sub mark_dom_rep{
    my @a_of_reps = @{$_[0]};

    my %rep_name_to_count;
    foreach my $rep (@a_of_reps){
	$rep_name_to_count{$rep->{REP_NAME}}++;
    }

    my $max;
    foreach (keys %rep_name_to_count){
	$max = $_ if !$max;
	$max = $_  if $rep_name_to_count{$_} > $rep_name_to_count{$max}
    }

    foreach my $rep (@a_of_reps){
	if ($rep->{REP_NAME} eq $max) {	$rep->{DOM} = 1 }
	else { $rep->{DOM} = 0 }
    }
    return \@a_of_reps;
}

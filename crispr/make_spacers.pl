# this scripts converts the simplified "rep_loc" files to spacers
# next script is the make_spacers_uniq.pl

use strict;
use warnings;
use Eco;

# http://www.sciencemag.org/content/327/5962/167.full.html
my $too_long = 72;
my $too_short = 20;

open TOO_SHORT, ">too_short";
open TOO_LONG, ">too_long";

clear_out_spacers();		# nuke existing spacers.

# these are the files where the repeat locations are found per isolate;
# mapping name to file location.
my %tp1_tp2_rep_locs = %{list_tp1_tp2_repeats()};
my %hi_cov_454_rep_locs = %{list_hi_covg_and_454_repeats()};

foreach my $isolate (keys %tp1_tp2_rep_locs){
    my %annots = %{load_repeat_loc_annotation($tp1_tp2_rep_locs{$isolate})};

    # grab the relevant contigs    
    my %contigs = %{load_specific_contigs(\%annots)};

    write_spacers(\%annots,\%contigs);
    # do small check making sure that the spacer seems sane.
}

foreach my $isolate (keys %hi_cov_454_rep_locs){
    my %annots = %{load_repeat_loc_annotation($hi_cov_454_rep_locs{$isolate})};

    # grab the relevant contigs    
    my %contigs = %{load_specific_contigs(\%annots)};

    write_spacers(\%annots,\%contigs);
}
    
close OUT;
close TOO_LONG;

my %ctg_to_repeats; #; = %{load_repeats(\@all_rep_locs)};

exit;

sub write_spacers{

    my %repeat_annots = %{$_[0]};
    my %contigs = %{$_[1]};

    foreach my $ctg_name (keys %repeat_annots){
	my $ctg_seq = $contigs{$ctg_name};

	next if $ctg_name =~ /BC|TP/;
	
	my @reps = @{$repeat_annots{$ctg_name}};

	my $spc_start=0;
	my $spcr_num=0;
	my $prev_rep ='';
	foreach my $repeat (sort { $a->{LOC} <=>$b->{LOC} } @{reps} ){
#	next unless $repeat->{STRAND} eq '-';
	    my $rep_end = $repeat->{LOC}+length($repeat->{SEQ});
	    next if $repeat->{OLAPS} && !$repeat->{DOM};
	    next unless $rep_end;

	    my $comp_rep = '';
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
}

foreach my $ctg_name (keys %ctg_to_repeats){
    # die "no ctg for $ctg_name\n" if !defined $contig_seqs{$ctg_name};
    my $ctg_seq;# = $contig_seqs{$ctg_name};
    
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

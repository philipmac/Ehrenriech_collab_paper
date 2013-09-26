# I am just doing this to cut down on load for blasting. 
# I output a mapper (? do I care about this?)

use warnings;
use strict;

print_uniq(load_seq([`ls /home/philip/e_reich/tp1/reads/*_31/bowtie_index/spacers.fa`]),'tp1');
print_uniq(load_seq([`ls /home/philip/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/spacers.fa`]),'tp2');
print_uniq(load_seq([`ls /home/philip/e_reich/tp1_454/*bowtie_index/spacers.fa`]), 'tp1_454');
print_uniq(load_seq([`ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/spacers.fa`]), 'tp1_ds');
print_uniq(load_seq([`ls /home/philip/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/bowtie_index/spacers.fa`]), 'tp1_hi_covg');

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

sub print_uniq{
    my %head_to_seq = %{$_[0]};
    my $tp = $_[1];

    my %seq_to_head = reverse %head_to_seq;

    my $i = 1;
    my %seen;
    open OUT, ">spacers_uniq.$tp.fa" or die $!;
    foreach (keys %seq_to_head){
	next if $seen{$_};
	$seen{$_}=1;
	print OUT ">$i.$tp\n$_\n";
	$i++;
    }
    close OUT;
}



# my @tp1;
# foreach my $file (@tp1){
#     open IN, $file or die $!;
#     my $lh;
    
#     while (<IN>){
# 	chomp $_;
# 	next if $_ =~ /^\s*$/;
# 	if ($_ =~ s/^>//){
# 	    $lh = $_;
# 	}
# 	else {
# 	    $tp1_head_to_seq{$lh}=$_;
# 	}
#     }
#     close IN;
# }

# foreach my $file (@tp2){
#     open IN, $file or die $!;
#     my $lh;
    
#     while (<IN>){
# 	chomp $_;
# 	next if $_ =~ /^\s*$/;
# 	if ($_ =~ s/^>//){
# 	    $lh = $_;
# 	}
# 	else {
# 	    $tp2_head_to_seq{$lh}=$_;
# 	}
#     }
#     close IN;
# }

# my $cnt = 0;

# open MAP, ">data/tp1_spacers_map" or die $!;
# open SPC, ">data/tp1_spacers.fa" or #die $!;
# # system "mkdir data/tp1_spacers" unless -d "data/tp1_spacers";

# my %tp1_seq_to_head = reverse %tp1_head_to_seq;
# foreach my $seq (keys %tp1_seq_to_head){
#     $cnt++;

#     my @sames;
#     foreach my $head (keys %tp1_head_to_seq){
# 	push @sames, $head if $tp1_head_to_seq{$head} eq $seq;
#     }
    
#     open SINGLE, ">data/tp1_spacers/$cnt.fa" or die $!;
#     my $same_str = join ',',@sames;
#     print MAP "tp1:$cnt\t@sames\n";
#     print SPC ">tp1:$cnt\n$seq\n";
#     print SINGLE ">tp1:$cnt\n$seq\n";
#     close SINGLE;
# }
# close MAP;
# close SPC;

# $cnt = 0;
# open MAP, ">data/tp2_spacers_map" or die $!;
# open SPC, ">data/tp2_spacers.fa" or die $!;

# # system "mkdir data/tp2_spacers" unless -d "data/tp2_spacers";

# my %tp2_seq_to_head = reverse %tp2_head_to_seq;
# foreach my $seq (keys %tp2_seq_to_head){
#     $cnt++;

#     my @sames;
#     foreach my $head (keys %tp2_head_to_seq){
# 	push @sames, $head  if $tp2_head_to_seq{$head} eq $seq;
#     }
	    
#     my $same_str = join ',',@sames;
#     open SINGLE, ">data/tp2_spacers/$cnt.fa" or die $!;
#     print MAP "tp2:$cnt\t@sames\n";
#     print SPC ">tp2:$cnt\n$seq\n";
#     print SINGLE ">tp2:$cnt\n$seq\n";
#     close SINGLE;
# }

# close MAP;
# close SPC;

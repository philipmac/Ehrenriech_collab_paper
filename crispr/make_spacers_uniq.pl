# I am just doing this to cut down on load for blasting. 
# I output a mapper (? do I care about this?)

use warnings;
use strict;
use Eco;

my %spacers = %{load_FA('../crispr/data/cat_spacers_in_study.fa')};

print_uniq(\%spacers);

exit;


sub print_uniq{
    my %head_to_seq = %{$_[0]};
    my %seq_to_head = reverse %head_to_seq;

    my $i = 1;
    my %mapper;
    open OUT, ">spacers_uniq.fa" or die $!;
    foreach my $spacer_seq (keys %seq_to_head){
	print OUT ">spacer_$i\n$spacer_seq\n";
	foreach (keys %head_to_seq){
	    $mapper{$_} = $i if $head_to_seq{$_} eq $spacer_seq;
	}
	$i++;
    }
    close OUT;

    open MAP, ">spacers_map.txt" or die $!;
    foreach (sort keys %mapper){
	print MAP $_.'=>'.$mapper{$_}."\n";
    }
    close MAP;

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

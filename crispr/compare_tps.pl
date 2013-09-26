# look up the crisprs in tp1, tp2
# globally what spacers have been added / lost 
# flip through the indivs, same. 

# read the spacer seqs in, 
# assoc with indiv
# chk changes 

use strict;
use warnings;

my %tp1 = %{load("data/tp1_spacers.fa")};
my %tp2 = %{load("data/tp2_spacers.fa")};

# what's been added or lost globally?
open LOST, ">data/lost_in_t2.csv";
foreach my $seq (keys %tp1){
    if (!defined $tp2{$seq}){
	print LOST $tp1{$seq},"\n",$seq,"\n";
    }
}
close LOST;

open ADD, ">data/new_in_t2.csv";
foreach my $seq (keys %tp2){
    if (!defined $tp1{$seq}){
	print ADD $tp2{$seq},"\n",$seq,"\n";
    }
}
close ADD;

open COMMON, ">data/common.csv";
my %u = map {$_=>1} (keys %tp1, keys %tp2);
foreach my $seq (keys %u){
    print COMMON  $tp2{$seq},"\n",$seq,"\n" if defined ($tp1{$seq}) && defined ($tp2{$seq});
}
close COMMON;

sub load{
    open IN, $_[0]  or die $!;
    my $head;
    my %h;
    while (<IN>){
	chomp;
	if ($_=~ /^>/){
	    $head = $_;
	}
	else{
	    $h{$_}=$head;
	}
    }
    close IN;
    return \%h;
}

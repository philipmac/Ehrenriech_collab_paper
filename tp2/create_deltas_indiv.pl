# step 3) get the deltas.
#     tp2.indiv1{ a=>(1-0)=1, 
#             b=>(1-1)=0,
#             c=>(2/3-1)=-0.33,
#             d=>(0-1/3)=-0.33,
#             e=>(1/3-1/3)=0,
#     f=>(0-1/3)=-1/3 }

# the "delta" is how far away from normal a gene's fractional representation changes from an indiv compared to everyone else
# that is, if a gene shows up in every single sample of indiv a, and never in anyone else, this gets a "1" (ie it's unique to that 
# person) (ie it's over represented)

# say a gene shows up in 1/3 of indiv1 barcodes, and a few other places:
# 1/3 => ind1 <-
# 0/4 => ind2 (since there are 4 other guys, each indv gets 1/4 weight => * scale) 
# 1/3 => ind3 (*1/4) = 1/12 
# 1/5 => ind4 (*1/4) = 1/20
# 0/3 => ind5
# the final delta is : 0.133

use warnings;
use strict;

my @fractions = `ls derived_data/tp2.fractions.1.txt derived_data/tp2.fractions.2.txt derived_data/tp2.fractions.3.txt derived_data/tp2.fractions.4.txt derived_data/tp2.fractions.5.txt`;

my @fracHashes;
my $scale = 1/4;

foreach my $fracFile (@fractions){
    my $indiv = $1 if $fracFile =~ /\.(\d)\.txt/;
    die "No indiv for $fracFile\n" if !$indiv;

    my %gene_to_frac;
    open IN, $fracFile or die $!;
    while (<IN>){
	chomp;
	my ($gene,$frac)=split /\t/;
	$gene_to_frac{$gene}=$frac;
    }
    close IN;
    $fracHashes[$indiv]=\%gene_to_frac;
}
    
foreach my $indiv (1..5){
    # grab the indiv we're working on
    my %gene_to_frac = %{$fracHashes[$indiv]};
    die "hash is undef\n" if scalar keys %gene_to_frac ==0;

    # find out the total of how much we need to decrement this indivs various gene fracs
    my %neg_total;
    foreach my $compare (1..5){
	next if $indiv == $compare;
	my %compHash = %{$fracHashes[$compare]};
	foreach (keys %compHash){
	    $neg_total{$_} += ($compHash{$_} * $scale);
	}
    }

    # do the sum
    my %gene_to_ans;
    foreach (keys %gene_to_frac){
	if ( !defined $neg_total{$_} ) { 
	    $gene_to_ans{$_} = 1 }
	else{
	    $gene_to_ans{$_} = $gene_to_frac{$_} - $neg_total{$_};
	}
    }
    
    open OUT, ">derived_data/delta_indiv.$indiv.csv" or die $!;
    foreach (sort {$gene_to_ans{$b} <=> $gene_to_ans{$a}} (keys %gene_to_ans)){
	print OUT $_,",",$gene_to_ans{$_},"\n";
    }
    close OUT;
}

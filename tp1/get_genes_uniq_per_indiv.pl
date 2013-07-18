# step 2) want to work out the fraction of samples PER INDIVIDUAL every gene occurs.
# tp1.indiv1{ a=>3/3=1.0, 
# 	    b=>3/3,
# 	    c=>2/3,
# 	    e=>1/3 }
# tp1.indiv2{ b=>1,c=>1,d=>1/2,e=>1/2 }

use strict;
use warnings;

# I want to know which barcode belongs to which host ie (1..5)
my %tp1_barcode_to_host;

open (IN, "derived_data/top_picks_merged_with_Ian_work") or die $!;
while (<IN>){
    #barcode E_coli_strain_called num_genes_common type host
    #AATGGC Escherichia_coli_CFT073_uid57915 3259 5 4
    chomp;
    next if $_ =~ /barcode/i;
    my ($sample,$strain,$num_gene,$type, $host) = split /\t/,$_;
    $tp1_barcode_to_host{$sample}=$host;
}
close IN;

# these ECO_GENE files are simply a presence absence call if ECO GENE X is found in sample <barcode>.
my @files_tp1 = `ls derived_data/ECO_GENE*`;

# I am curious to see what gene is the MOST represented here. That is, if I see some gene in a single sample
# that's not the same as seeing it in every sample in that indiv...
my %host_to_gene_count;
foreach (@files_tp1){
    open IN, $_ or die;
    chomp;
    my $bc =$1 if ($_ =~ /HOST\.(\w+)/);
    next if $bc eq'CGAAAT';
    my $host= $tp1_barcode_to_host{$bc};
    die "no host lookup for $_\n" if $host eq '';
    while (<IN>){
	chomp;
	my @a = split /\t/,$_;
	$host_to_gene_count{$host}{$a[0]}++;
    }
    close IN;
}


# flip through every individual:
#   find out how many samples this indiv got (num barcodes)
#   find out the fraction of samples each gene was found per individual, and write this out.
foreach my $host (keys %host_to_gene_count){
    my %gene_to_count = %{$host_to_gene_count{$host}};

    # how many barcodes are there in each host (divisor)
    my $divisor=0;
    foreach(keys %tp1_barcode_to_host){
	die "no barcode for $_\n" if !defined $tp1_barcode_to_host{$_};
	die "host is bad \n" if $host eq "";
	next if $_ eq 'CGAAAT';	# this is just a bad well for some reason, according to Ian
	$divisor++ if $tp1_barcode_to_host{$_}==$host;
    }

    # fraction of samples each gene was found per individual
    open INDIV_TP1, ">derived_data/tp1.fractions.$host.txt" or die $!;
    foreach (sort {$gene_to_count{$a}<=>$gene_to_count{$b}} keys %gene_to_count){
	print INDIV_TP1  $_,"\t", sprintf("%.3f",$gene_to_count{$_}/$divisor) ,"\n";
    }
    close INDIV_TP1;    
}


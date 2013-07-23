# this looks to see what has changed over the two time points / indiv
# Delta individual

use strict;
use warnings;

my %tp1;
my %tp2;

my @files_tp1 = `ls ../tp1/derived_data/ECO_GENE*`;
my @files_tp2 = `ls derived_data/ECO_GENE*`;

foreach (@files_tp1){
    open IN, $_ or die;
    chomp;
    my $host =$1 if ($_ =~ /HOST\.(\d)/);
    while (<IN>){
	chomp;
	$tp1{$host}{$_}++;
    }
    close IN;
}

foreach (@files_tp2){
    open IN, $_ or die;
    chomp;
    my $host =$1 if ($_ =~ /HOST\.(\d)/);
    while (<IN>){
	chomp;
	$tp2{$host}{$_}++;
    }
    close IN;
}

foreach my $indiv(keys %tp1){

    my %genes_uniq_tp1 = %{$tp1{$indiv}};
    my %genes_uniq_tp2 = %{$tp2{$indiv}};
    foreach (keys %tp1){
	next if $_==$indiv;
	foreach (keys %{$tp1{$_}}){
	    delete $genes_uniq_tp1{$_};
	}
	foreach (keys %{$tp2{$_}}){
	    delete $genes_uniq_tp2{$_};
	}
    }

    open INDIV_TP1, ">derived_data/tp1.$indiv.only";
    print INDIV_TP1 join "\n",keys %genes_uniq_tp1;
    close INDIV_TP1;

    open INDIV_TP2, ">derived_data/tp2.$indiv.only";
    print INDIV_TP2  join "\n",keys %genes_uniq_tp2;
    close INDIV_TP2;
}

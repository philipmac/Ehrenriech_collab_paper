# this looks to see what has changed over the two time points / indiv

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
	$tp1{$host}{$_}=1;
    }
    close IN;
}

foreach (@files_tp2){
    open IN, $_ or die;
    chomp;
    my $host =$1 if ($_ =~ /HOST\.(\d)/);
    while (<IN>){
	chomp;
	$tp2{$host}{$_}=1;
    }
    close IN;
}

foreach my $indiv(keys %tp1){
    open TP1_ONLY, ">derived_data/tp1_only.$indiv";
    foreach (keys %{$tp1{$indiv}}){
	print TP1_ONLY "$_\n" unless $tp2{$indiv}{$_};
    }
    close TP1_ONLY;

    open TP2_ONLY, ">derived_data/tp2_only.$indiv";
    foreach (keys %{$tp2{$indiv}}){
	print TP2_ONLY "$_\n" unless $tp1{$indiv}{$_};
    }
    close TP2_ONLY;
}

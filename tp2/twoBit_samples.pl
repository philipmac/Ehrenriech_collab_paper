#!/usr/bin/perl -w
use strict;

my @files = `ls ~/e_reich/tp2/reads/*/k_31_covg_30/contigs.fa`;

foreach my $file(@files){
    chomp $file;
    my $outFile = $file;
    $outFile =~ s/fa$/2bit/;
    next if (-e $outFile);
    system "~/bin/x86_64-linux-gnu/faToTwoBit $file $outFile";

}

#!/usr/bin/perl -w
use strict;

my @files = `ls ../ECO_ALL/*/*fa`;

foreach my $file(@files){
    chomp $file;
    my $outFile = $file;
    $outFile =~ s/fa$/2bit/;
    next if (-e $outFile);
    system "~/bin/x86_64-linux-gnu/faToTwoBit $file $outFile";
}

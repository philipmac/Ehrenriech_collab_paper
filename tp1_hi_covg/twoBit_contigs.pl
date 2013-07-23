# index the full coverage fa files

use warnings;
use strict;

my @files = `ls ~/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/contigs.fa`;

foreach my $file(@files){
    chomp $file;
    my $outFile = $file;
    $outFile =~ s/fa$/2bit/;
    next if (-e $outFile);
    system "~/bin/x86_64-linux-gnu/faToTwoBit $file $outFile";
}

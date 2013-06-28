# index the down sampled fa files

use warnings
use strict;

my @files = `ls ../reads/*/*_ds_4k_31_covg_30/contigs.fa`;

oreach my $file(@files){
    chomp $file;
    my $outFile = $file;
    $outFile =~ s/fa$/2bit/;
    next if (-e $outFile);
    system "~/bin/x86_64-linux-gnu/faToTwoBit $file $outFile";
}

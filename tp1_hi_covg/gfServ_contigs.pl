# this inits all of the blat servers and records what port they are all running on in port_to_Ecoli

use strict;
use warnings;

my @samples = `ls ~/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/contigs.2bit`;

open OUT , ">derived_data/port_to_contig" or die $!;

my $hostNum = 80140;		# start at this port, and go up.

foreach my $sample (@samples){
    chomp $sample;
    print "trying.... $sample,\t,$hostNum,\n";

    system(" ~/bin/x86_64-linux-gnu/gfServer start localhost $hostNum $sample &");
    sleep(1);

    print OUT $sample,"\t",$hostNum,"\n";
    $hostNum++;
}
close OUT;

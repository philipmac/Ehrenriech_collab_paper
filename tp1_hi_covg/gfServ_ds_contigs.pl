# this inits all of the blat servers and records what port they are all running on in port_to_Ecoli

use strict;
use warnings;
my $root = '../reads';
my @samples = `ls $root/*/*_ds_4k_31_covg_30/contigs.2bit`;

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

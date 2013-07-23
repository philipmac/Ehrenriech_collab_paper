# this inits all of the blat servers and records what port they are all running on in port_to_Ecoli

use strict;
use warnings;

my @strains = `ls ~/genomes/ECO_ALL`;

open OUT , ">derived_data/port_to_Ecoli" or die $!;

my $hostNum = 80080;		# start at this port, and go up.

foreach my $strain (@strains){
    next if $strain =~ /perl/;
    chomp $strain;
    my @bitFiles = `ls ~/genomes/ECO_ALL/$strain/*2bit`;
    my @bitFilesNoCR;
    foreach my $file (@bitFiles){
	chomp $file;
	push @bitFilesNoCR,$file;
    }

    # my @a = split /\//,$strain;
    # my $strain = $a[$#a-1];

    print "trying.... $strain,\t,$hostNum,\n";

    system(" ~/bin/x86_64-linux-gnu/gfServer start localhost $hostNum @bitFilesNoCR &") or print "failed $!";
    sleep(1);

    print OUT $strain,"\t",$hostNum,"\n";
    $hostNum++;

}
close OUT;

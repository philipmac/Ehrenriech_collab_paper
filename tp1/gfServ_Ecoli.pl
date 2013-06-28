use strict;
use warnings;

my @strains = `ls ../ECO_ALL`;

open OUT , ">port_to_Ecoli" or die $!;

my $hostNum = 80080;		# start at this port, and go up.

foreach my $strain (@strains){
    next if $strain =~ /perl/;
    chomp $strain;
    my @bitFiles = `ls ../ECO_ALL/$strain/*2bit`;
    my @bitFilesNoCR;
    foreach my $file (@bitFiles){
	chomp $file;
	push @bitFilesNoCR,$file;
    }

    # my @a = split /\//,$strain;
    # my $strain = $a[$#a-1];

    print "trying.... $strain,\t,$hostNum,\n";

    system(" ~/bin/x86_64-linux-gnu/gfServer start localhost $hostNum @bitFilesNoCR &") or print "failed $!";
    sleep(5);

    print OUT $strain,"\t",$hostNum,"\n";
    $hostNum++;
#    last;
}
close OUT;

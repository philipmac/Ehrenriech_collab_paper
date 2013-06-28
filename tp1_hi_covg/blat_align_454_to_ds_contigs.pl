#NOT RUN YET

use strict;
use warnings;

open (IN, "derived_data/port_to_contig") or die $!;
my %eColiToPort;
my %portToDir;
while (<IN>){
    chomp;
    my ($sp,$prt) = split /\t/,$_;
    my (undef, undef,$sample) = split /\//,$sp;
    $eColiToPort{$sample}=$prt;
    $sp =~ s/\.2bit//;
    $portToDir{$prt}=$sp;
}
close IN or warn $!;


my @fffs = `ls ~/e_reich_tp1_454/*fasta`;
my $fuckingBullshit = '.';

foreach my $fff (@fffs){
    chomp  $fff;

    my $wellName = '';
    if ($fff =~ /.*\/(\w+)\.fasta/){
	$wellName = $1;
    }

    my $port = $eColiToPort{$wellName};
    next unless $port;
    
    my $outFile = $portToDir{$eColiToPort{$wellName}}.'_vrs_454.psl';

    system "~/bin/x86_64-linux-gnu/gfClient localhost $port $fuckingBullshit $fff $outFile\n";
}



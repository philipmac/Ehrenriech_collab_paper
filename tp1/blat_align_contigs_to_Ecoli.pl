use strict;
use warnings;

open (IN, "port_to_Ecoli") or die $!;
my %eColiToPort;
while (<IN>){
    chomp;
    my ($sp,$prt) = split /\t/,$_;
    $eColiToPort{$sp}=$prt;
}
close IN or warn $!;


my @strains = `ls ../ecolireads/*_31/contigs.fa`;
my $fuckingBullshit = '.';

foreach my $strainFile (@strains){
    chomp  $strainFile;
    my $blatDir = $strainFile;
    $blatDir =~ s/contigs\.fa/blat/;
    system "mkdir $blatDir\n" unless (-d $blatDir);

    foreach my $eColi (keys %eColiToPort){
	chomp $eColi;
	my $port = $eColiToPort{$eColi};
	my $outFile = $blatDir.'/'.$eColi.'.psl';

	system "~/bin/x86_64-linux-gnu/gfClient localhost $port $fuckingBullshit $strainFile $outFile\n";
    }
}



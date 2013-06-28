# this is the guy that joins "shuffles" the ends of the read together to create one single merged read.
use strict;
use warnings;

my @ones= `ls ../reads/*/1_*.fq`;
foreach (@ones){
    chomp $_;
    my $two = $_;
    $two =~ s/1_/2_/;
    my $out = $_;
    $out =~ s/1/merged/;
    system "/usr/share/velvet/shuffleSequences_fasta.pl $_ $two $out";
}

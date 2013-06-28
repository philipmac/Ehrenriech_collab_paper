use strict;
use warnings;

my @ones= `ls ../reads/*/1.fa`;
foreach (@ones){
    chomp $_;
    my $two = $_;
    $two =~ s/1/2/;
    my $out = $_;
    $out =~ s/1/merged/;
    system "/usr/share/velvet/shuffleSequences_fasta.pl $_ $two $out";
}

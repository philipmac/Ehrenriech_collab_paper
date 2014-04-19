use warnings;
use strict;
use Eco;

my @files = `ls ~/e_reich/tp1/reads/*_31/blat/gene_calls/E*.csv`;

foreach my $file (@files){    
    chomp $file;

    my %ecogenes = %{look_for_ecogenes_in($file)};

    my $outFile = $file;
    $outFile =~ s/\.csv/\.ECO_GENES/;

    open OUT, ">$outFile" or die $!;
    print OUT join "\n", (sort {$a cmp $b} keys %ecogenes);
    close OUT;
}

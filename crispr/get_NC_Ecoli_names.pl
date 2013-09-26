# I want to just pull all the NC sort names into one place (that is the ones that
# refer to E coli...)

my @files = `ls /home/philip/genomes/ECO_ALL/Escherichia_coli*/*.gff`;

open OUT, ">NC_NAME_E_coli.txt";
foreach my $file (@files){
    chomp $file;
    $file =~ s/\.gff//;
    my @l= split /\//,$file;
    
    print OUT ($l[$#l],"\t",$l[$#l-1]);
    print OUT "\n";
}
close OUT;
    

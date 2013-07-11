use strict;
use warnings;

my %barcode_to_host;

open IN, 'derived_data/barcodes_tp2.txt' or die $!;
while (<IN>){
    # F=>1; I=>2, J=>3, S=>4 L=>5.
    chomp $_;
    next if $_ =~ /exclude/;
    my ($bc,$well,undef) = split /\t/,$_;

    if ($well =~ /^F/){
        $barcode_to_host{$bc}='1';
    }
    elsif ($well =~ /^I/){
        $barcode_to_host{$bc}='2';
    }
    elsif ($well =~ /^J/){
        $barcode_to_host{$bc}='3';
    }
    elsif ($well =~ /^S/){
        $barcode_to_host{$bc}='4';
    }
    elsif ($well =~ /^L/){
        $barcode_to_host{$bc}='5';
    }
    else{
        die "print Borking on $_\n";
    }
}
close IN;

# open up all the eck gene lists, 
# sort them into which host they are in
# print hosts

my %host_to_ECO_genes;

my @files = `ls ~/e_reich/tp2/reads/*/k_31_covg_30/blat/*.ECO_GENES_hit`;
foreach my $file (@files){
    chomp $file;
    open IN, $file or die $!;

    my (undef,undef,undef,undef,undef,undef,$barcode,undef,undef) = split /\//,$file;

    next if $barcode =~ /CGAAAT/;

    my $host = $barcode_to_host{$barcode};
    print $file,"\n" if $host eq '';
    while (<IN>){
	chomp $_;
	$host_to_ECO_genes{$host}{$_}=1
    }
    close IN;
}


foreach my $host (keys %host_to_ECO_genes){
    open OUT, ">derived_data/ECO_GENE_tp1_HOST.$host";
    foreach (keys %{$host_to_ECO_genes{$host}}){
	print OUT $_,"\n";
    }
    close OUT;
}

# aiming here to categorise the alignments. 
# Homo sapiens
# Escherichia coli O55:H7 str.
# phage
# Culex quinquefasciatus <-- mosquito??
# CRISPR

use strict;
use warnings;

my @tps = qw (tp1_454 tp1_ds tp1_hi_covg tp1 tp2);



foreach my $tp (@tps){
    my @summaries = `ls data/blast_output/$tp.summary*`;
    my %samples_seen;		# want to make sure that every sample has been seen
    foreach my $summary (@summaries){
	chomp $summary;
	open IN, $summary or die $!;
	my %count;
	while (<IN>){
	    next unless $_ =~ /^\d/;
	    my @a = split /\t/;
	    $count{$a[0]}=1;	# a[0] is the sample number
	    $samples_seen{$a[0]}=1;
	}
	close IN;

	$summary =~ s/data\/blast_output\///;
	print $summary, "\t",  scalar keys %count, "\n";
    }

    # flip through the samples seen to make sure they are continious
    my $i = 0;
    while($i < scalar keys %samples_seen){
	$i++;
	next if defined $samples_seen{$i};
	print "Missing $i from $tp!!\n";
    }
    print  "$i in $tp :)\n\n";
}

exit;

#open OUT, ">spacer_classification.csv" or die $!;

# foreach my $summary (@summaries){

#     my %hits = %{examine($summary)};

#     if ($summary =~ /tp1/){

	
# 	foreach my $i (1..84){	# tp1
# 	    my $id = "tp1:$i";
# 	    # print OUT $id,"\n" if ! exists $hits{$id};
# 	    print OUT $id;
# 	    defined $hits{$id}{e_coli_CRISPR} ? print OUT "\tY":print OUT "\tN";
# 	    defined $hits{$id}{other_CRISPR} ? print OUT "\tY":print OUT "\tN";
# 	    defined $hits{$id}{phage} ? print OUT "\tY":print OUT "\tN";
# 	    defined $hits{$id}{human_genomic} ? print OUT "\tY":print OUT "\tN";
# 	    print OUT"\n";
# 	}
#     }
#     else{
# 	foreach my $i (1..488){	# tp2
# 	    my $id = "tp2:$i";
# 	    print OUT $id;
# 	    defined $hits{$id}{e_coli_CRISPR} ? print OUT "\tY":print OUT "\tN";
# 	    defined $hits{$id}{other_CRISPR} ? print OUT "\tY":print OUT "\tN";
# 	    defined $hits{$id}{phage} ? print OUT "\tY":print OUT "\tN";
# 	    defined $hits{$id}{human_genomic} ? print OUT "\tY":print OUT "\tN";
# 	    print OUT"\n";

# 	}
#     }

# }

sub examine{
    my $file = $_[0];
    open IN, $file or die $!;
    
    my %h;
    
    while (<IN>){
	chomp;
	my ($id,$info)=split /\t/;
	$h{$id}{e_coli_CRISPR}++ if ($_ =~ /Escherichia coli/i) && ($_ =~ /CRISPR/);
	$h{$id}{other_CRISPR}++ if ($_ !~ /Escherichia coli/i) && ($_ =~ /CRISPR/);
	$h{$id}{phage}++ if ($_ =~ /phage/i);
	$h{$id}{human_genomic}++ if $_ =~ /Homo sapiens chromosome/i;

    }
    close IN;
    return \%h;
}

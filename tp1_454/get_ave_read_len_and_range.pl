# look up some statistics for the 454 data.
use strict;
use warnings;

my @fas =  `ls ../../tp1_454/*fasta`;
my %wellToStats;
foreach my $fa (@fas){
    open (IN, $fa) or die $!;

    my %h;
    my $head='';
    while (<IN>){
	chomp $_;

	if ($_ =~ /^>/){
	    my @heads = split /\s/,$_;
	    $heads[0] =~ s/>//;
	    $head=$heads[0];
	}
	else{
	    $h{$head}.=$_;
	}
    }
    my $avg =  sprintf("%.3f",get_ave_val_len(\%h));
    my $stdD = sprintf("%.3f",get_stdev(\%h,$avg));
    my $well = $1 if($fa=~ /\/(\w+)\.fasta/);
    $wellToStats{$well}{a}=$avg;
    $wellToStats{$well}{s}=$stdD;
}

my ($totAv, $avStdDev);
foreach my $well (keys %wellToStats){
    print "Well $well; ave len: ".$wellToStats{$well}{a}." std dev: ".$wellToStats{$well}{s}."\n";
    $totAv+=$wellToStats{$well}{a};
    $avStdDev+=$wellToStats{$well}{s};
}

$totAv = sprintf("%.3f",($totAv/(scalar @fas)));
$avStdDev = sprintf("%.3f",($avStdDev/(scalar @fas)));

print "\nAverage : $totAv\n";
print "\nAve std dev : $avStdDev\n";

sub get_stdev{
    my($d,$av) = ($_[0],$_[1]);
    my @vals = values %{$d};
    if(scalar @vals == 1){
	return 0;
    }

    my $sqtotal = 0;
    foreach(@vals) {
	$sqtotal += ($av-length($_)) ** 2;
    }
    my $std = ($sqtotal / (scalar @vals)) ** 0.5;
    return $std;
}

sub get_ave_val_len{
    my $totLen=0;
    foreach (values %{$_[0]}){
	$totLen += length($_)
    }
    return $totLen/(scalar keys %{$_[0]});
}

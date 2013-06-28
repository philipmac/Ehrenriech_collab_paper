# the fasta file is not split into its barcoded samples, I need to sort this. 
# not tested! Not even run once...

use strict;
use warnings;
use IO::Handle;


# system"rm -rf ../reads/A* ../reads/T* ../reads/C* ../reads/G*";
# exit;

die "Give me an ARGV for the file name...!" unless ($ARGV[0] && -e $ARGV[0]); # weird,if execution goes left to right?

my %valid;
open IN, "../reads/barcodes.txt";
while (<IN>){
    chomp;
    next if $_ =~ /exclude/;
    my ($bc,undef) = split /\t/,$_;
    $valid{$bc}=1;
}
close IN;

# print keys %valid;
# exit;

open IN, $ARGV[0] or die $!;


my %bcToFH;			# barcode to filehandle.
my $head='';
my $barcode='';

while (<IN>){

# >DLZ38V1_0230:6:1101:1176:2048#AGAACC/2
# TATTGATACTCCAAGTGAAAACACTTCCGTTATCTTGGATCCACCACGCAAGGGCTGTGACGAATTATTACTAAAGCAATTAGCCGCATATAATACAGCC
# >DLZ38V1_0230:6:1101:1024:2055#GATATA/2
# GCATTGCACCACCAGAGCGTCATACAGCGGCTTAACAGTGCGTGACCAGGTGGGTTGAGTAAGGTTTGGGATTAGCATCGTTACAGCGCGGTATGCGGCG

    chomp;
    if($_ =~ /^>/){
	$head=$_;
	(undef, $barcode)=split /#/;
	$barcode =~ s/\/\d//;
	$barcode = '' unless $valid{$barcode};
	next if $barcode eq '';

#	$bcToFH{$barcode}=$_;
	system "mkdir ../reads/$barcode" unless (-d "../reads/$barcode");

	unless (exists $bcToFH{$barcode}){
	    my $fileName;
	    if ($ARGV[0] =~ /s_6_1/){
		$fileName = '../reads/'.$barcode.'/1.fa';
	    }
	    else{
		$fileName = '../reads/'.$barcode.'/2.fa';
	    }
	    
	    # $io = new IO::Handle;	
	    # if ($io->fdopen(fileno(STDOUT),"w")) {
	    # 	$io->print("Some text\n");
	    # }
	    local *FILE;
	    open(FILE, '>',$fileName) or die "cannot open > $fileName: $!";
	    $bcToFH{$barcode}=*FILE;
	}
    }
    elsif ($barcode ne ''){
	
    	#print "trying $barcode \n"; 
	
    	my $fh=$bcToFH{$barcode};
    	print $fh $head."\n$_\n";#.$_." -- $barcode\n";
    }
}

# foreach (sort {$a cmp $b} (keys %bcToFH)){
#     print $_," ",$bcToFH{$_},"\n";
# }

# the idea is we want to generate some unique tag for each gene, small as possible. 
# take head and tail, both strands

# just use one genome for the time being, the others are getting in the way
use strict;
use warnings;


# this is the output of the dialign work, seeing if the genes are really exact orthologues or maybe not.
my %dialignMap;
my %allTags;

open IN, 'derived_data/GENE_ALIGNMENT_GOOD' or die $!;
while (<IN>){

    # gi_260853213_ref_NC_013361.1_1603601_1607077
    # gi|222154829|ref|NC_011993.1|:c3745292-3745185
     # gi|209395693|ref|NC|011353.1|:2712070-2712855
    chomp;
    
    my ($g,$v)=split "\t",$_;
    my $end='';
    my (@a,@b);
    if ($g =~ /,/){
        @b = split ',',$g;
	my $c=1;
	foreach (@b){
	    if($c==1){
		$c=0;
	    }
	    else{
		$end .= $_.',';
	    }
	}

	chop $end;

	$end =~ s/_/-/g;

	@a = split '_',$b[0];
    }
    else{
	@a = split '_',$g;
    }


    my $cords=':'.$a[$#a-1].'-'.$a[$#a];
    $cords.= ','.$end if $end;

    my $name = join '|',(@a[0..$#a-2],$cords);
    $name =~ s/NC\|/NC_/;
    $dialignMap{$name}=$v;
#    print $name,"\n";
    
}

print join "\t",qw/STRAIN_NAME N GENES TAGS TOO_SML DUPS DUPS_IMPERF/;
print "\n";

my @allfiles = `ls ../ecoliGenez/*`;
my @files;
foreach my $file(@allfiles){
    chomp $file;
    my $fileSize = -s $file;
    push  @files,$file;
}

foreach my $n (20){		# ,60,70,80,90,100,110,120
    foreach my $file (@files){
	my $genesRef = read_file_in($file);
	my $strain=$file;
	$strain =~ s/\.\.\/ecoliGenez\/|\.ffn//g;

	runDups($n,$genesRef,$strain);
    }
}

sub read_file_in{
    my %genes;
    my $file = $_[0];
    open IN, $file or die $!;
    my $header='';
    my $seq = '';

    while (<IN>){
	chomp;
	next if $_ =~ /^\s+$/;
	if ($_ =~ /^>(.*)/){
	    $genes{$header}=$seq if $header ne '';
	    $seq='';
	    $header = $1;
	}
	else{
	    $seq .=$_;
	}
    }
    $genes{$header}=$seq;
    close IN;    
    return \%genes;
}

# my @genesLen = sort {length($genes{$a}) <=> length($genes{$b})} keys %genes;
# print length($genesLen[0]);
# exit;
sub runDups{
    my $n = $_[0];
    my %genes = %{$_[1]};
    my $strain = $_[2];

    my %tags;
    my %tooSmall;
    my $notID =0;
    my $idCnt = 0;
    open TOO_SMALL, ">tags/too_small_$n.$strain";
    open DUPS, ">tags/dups_$n.$strain";
    open SHORT_DUPS, ">tags/shrt_dups_$n.$strain";

    foreach my $gene (keys %genes){
	my $geneStart= $gene;
	$geneStart =~ s/\s+.*//;
	my $seq = $genes{$gene};
	my ($head,$tail);
	if (length($seq) < $n){	# gene len is less than $n
	    print TOO_SMALL "$gene \n";
	    $tooSmall{$seq}=1;

	    if (defined $tags{$seq}){ # seen this guy before...?
		my $prevName = $tags{$seq};
#		print "pre name $prevName\n";
		$prevName =~ s/\|small.*//;
#		print "post name $prevName\n";

		if ($genes{$prevName} eq $genes{$gene} || $dialignMap{$geneStart}){
		    print SHORT_DUPS "--IDENTICAL--\n";
		    $idCnt++;
		}
		else{
		    print SHORT_DUPS "--NOT IDENTICAL--\n";
		    $notID++;
		}
		print SHORT_DUPS "$gene\n$genes{$gene}";
		print SHORT_DUPS "$tags{$seq}";
	    }

	    # just use whole gene.
	    $tags{$seq}=$gene.'|small_f';
	    $tags{rc($seq)}=$gene.'|small_rc';
	}

	elsif (defined $tags{head($seq,$n)}){ # if we've seen this tag already

	    my $str = $tags{head($seq,$n)};
	    $str =~ s/\|(head|tail).*//;

	    if ($genes{$str} eq $genes{$gene} || $dialignMap{$geneStart}){
		print DUPS "--IDENTICAL--\n";
		$idCnt++;
	    }
	    else{
		print DUPS "--NOT IDENTICAL--\n";
		$notID++;
	    }
	    print DUPS ">$gene\n";	       # name of gene
	    print DUPS $genes{$gene},"\n";
	    print DUPS '>'.$tags{head($seq,$n)},"\n"; # name we saw it earlier


	    print DUPS $genes{$str};
	    print DUPS "\n-\n";
	}
	else{
	    $allTags{head($seq,$n)}=1;
	    $allTags{tail($seq,$n)}=1;
	    $allTags{rc(head($seq,$n))}=1;
	    $allTags{rc(head($seq,$n))}=1;

	    $tags{head($seq,$n)}=$gene.'|head_f';
	    $tags{tail($seq,$n)}=$gene.'|tail_f';
	    $tags{rc(head($seq,$n))}=$gene.'|head_rc';
	    $tags{rc(tail($seq,$n))}=$gene.'|tail_rc';
	}
    }

    close TOO_SMALL;
    close DUPS;

    open OUT, ">tags/E_coli_tags_$n.$strain.fa";
    foreach my $seq (sort keys %tags){
	print OUT ">$tags{$seq}\n$seq\n"
    }
    close OUT;

    print join "\t",($strain,$n,scalar keys %genes,(scalar keys %tags), (scalar keys %tooSmall), $idCnt, $notID, (scalar keys %allTags));
    print "\n";
}

sub head{
    return substr $_[0], 0, $_[1];
}

sub tail{
    return substr $_[0], -$_[1];
}

    

sub rc {
    my $dna = shift;
    my $revcomp = reverse($dna);

    # complement the reversed DNA sequence
    $revcomp =~ tr/ACGTacgt/TGCAtgca/;
    return $revcomp;
}

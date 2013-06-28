
use warnings;
use strict;
my @dirs = `ls /mnt/disk2/philip/e_reich_tp1/ECO_ALL/`;

my $tagOnly=0;
my $tag=0;
my %NC_toLoc;

open MAP, ">map";

foreach my $dir(@dirs){

    chomp $dir;
    next unless $dir =~ /^Escherichia_coli/;

    my @asns=`ls /mnt/disk2/philip/e_reich_tp1/ECO_ALL/$dir/*.asn`;

    # data gene {
    #             locus "thrA",
    #             locus-tag "EC042_0001"
    # },
    # 	    location int {
    #             from 335,
    #             to 2797,
    #             strand plus,
    #             id gi 387605479
    # 		},
    # 	    dbxref {
    # 		{
    #               db "GeneID",
    #               tag id 12885303
    # 			}

    # YP_002406055.1

    my %geneInfo;
    foreach my $asn(@asns){
#	next unless $asn =~ /NC_011748/; #NC_017626
#	next unless $asn =~ /NC_000913/;
	my %info;

	my $geneOn=0;
	my $synOn=0;
	my $dbxOn=0;
	my $ecoGene=0;
	my $locationOn=0;
	my $locationMixOn=0;

	my @a=split /\//,$asn;
	my $sp = $a[$#a-1];
	my $chr = $1 if $a[$#a] =~ /(\w+)\.asn/;
	
	open IN, $asn or die $!;

	while(<IN>){
	    chomp $_;
	    $geneOn=1 if ($_ =~ /data gene {/);

	    if ($geneOn){
		$info{LOCUS} = $1 if ($_ =~ /locus "(\w+)"/);

		$synOn=1 if $_ =~ /syn {/;
		if ($synOn){
		    push @{$info{SYNS}}, $1 if $_ =~ /"(\w+)"/;
		}
		if ($_ =~ /},/){
		    if ($synOn){
			$synOn=0;
		    }
		    else{
			$geneOn=0
		    }
		}

		$info{LOCUSTAG} = $1 if ($_ =~ /locus-tag "(.*)"/);
	    }

	    next unless $info{LOCUSTAG};
	    
	    $dbxOn=1 if $_ =~ /dbxref/;
	    
	    if ($dbxOn){
		$ecoGene=1 if $_ =~ /EcoGene/;
		if ($ecoGene && ($_ =~ /tag str "(\w+)"/)){
		    $info{ECO_GENE} = $1;
		    $ecoGene=0;
		}

		if ($_ =~ /},/){
		    write_out(\%info,$chr,$dir);

		    %info=();
		    $dbxOn=0;
		}
	    }

	    $locationOn=1 if ($_ =~ /location int {/);
	    if ($locationOn){
		$info{FROM} = $1+1 if ($_ =~ /from c?(\d+),/);
		$info{TO}= $1+1 if ($_ =~ /to (\d+),/);
		$info{STRAND}=$1 if ($_ =~/strand (plus|minus),/);
		$locationOn=0 if ($_ =~ /},/);
	    }



	    $locationMixOn=1 if $_ =~ /location mix {/;
	    if ($locationMixOn){
		push @{$info{FROM_MIX}}, $1+1 if ($_ =~ /from c?(\d+),/);
		push @{$info{TO_MIX}}, $1+1 if ($_ =~ /to (\d+),/);
		$info{STRAND}=$1 if ($_ =~/strand (plus|minus),/);
#		my %params = map { $_ => 1 } @{$info{FROM_MIX}} if exists $info{FROM_MIX};
#		print $info{STRAND},"\n" if (exists $info{STRAND} && exists $params{1676305});
		$locationMixOn=0 if ($_ =~ /},/);
	    }

	}
	close IN;
    }
}


 	    # $info{GENEID} = $1 if ($info{GENEID} && $_ =~ /tag id (\d+)/);

	    # if ($_ =~ /db "(\w+)"/){
	    # 	if ($1 eq 'EcoGene'){
	    # 	    $info{ECO_GENE}=1;
	    # 	}
	    # 	elsif ($1 eq 'GeneID'){
	    # 	    $info{GENEID}=1;
	    # 	}
	    # }


# data gene {
#                 locus "yedN",
#                 syn {
#                   "ECK1932",
#                   "JW1918",
#                   "JW5912",
#                   "yedM"
#                 },
#                 locus-tag "b4495"
# },
#     location int {
#                 from 2009246,
#                 to 2010374,

# asn:
# location int {
#                 from 3732,
#                 to 5018,
#                 id gi 209917191
# },

# fa:
# 3733-5019

# location int {
#                 from 16838,
#                 to 16990,
#                 strand minus,
#                 id gi 387605479
# },


sub write_out{
    my %h = %{$_[0]};
    my ($chr,$str)=($_[1],$_[2]);

    my $isMixed =0;

    my @froms;
    my @tos;

    if (defined $h{FROM_MIX}){
	$isMixed = 1;
	@froms = @{$h{FROM_MIX}};
	@tos = @{$h{TO_MIX}};
    }

    if (!exists $h{STRAND}){
	
	# if (
	#     ((!exists $h{FROM}) || (!exists $h{FROM_MIX}))   || 
	#     ((!exists $h{TO}) || (!exists $h{TO_MIX}))) {
	#     print "problem at $chr,$str\n";
	#     print join "\n",values %h;
	#     print "\n";
	#     return;
	# }
	if (!$isMixed){
	    if ($h{FROM}<$h{TO}){
		$h{STRAND}='plus'
	    }
	    else{
		$h{STRAND}='minus';
	    }
	}
	else{
	    if ($froms[0]<$tos[0]){
		$h{STRAND}='plus'
	    }
	    else{
		$h{STRAND}='minus'
	    }
	}
    }

    my $loc ='';
    if (!$isMixed){
	if ($h{STRAND} eq 'minus'){
	    $loc = "c$h{TO}-$h{FROM}";
	}
	else {
	    $loc = "$h{FROM}-$h{TO}";
	}
    }
    else{
	if ($h{STRAND} eq 'minus'){
	    $loc = "c$tos[0]-$froms[0]";
	}
	else{
	    $loc = "$froms[0]-$tos[0]";
	}
    }

    my $synStr='SYNS: ';
    $synStr .= join ',',@{$h{SYNS}} if defined $h{SYNS};

    my $ecoGene='ECOGENE: ';
    $ecoGene .= $h{ECO_GENE} if defined $h{ECO_GENE};

    my $geneID='GENEID: ';
    $geneID .= $h{GENEID} if defined $h{GENEID};

    my $locus='LOCUS: ';
    $locus .= $h{LOCUS} if defined $h{LOCUS};

    my $locusTag='LOCUSTAG: ';
    $locusTag .= $h{LOCUSTAG} if defined $h{LOCUSTAG};

    print MAP join "\t", ($str,$chr,$loc, $locusTag, $locus, $synStr, $ecoGene, $geneID);
    print MAP "\n";
}

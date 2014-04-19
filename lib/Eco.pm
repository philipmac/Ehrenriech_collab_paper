package Eco;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw (
look_for_ecogenes_in
get_coli_name_from_file
strip_blat_cols
make_plasmid_loc_to_locus
rm_EC
load_plate_letters_to_int 
load_ECO_genes_by_bc 
load_sample_to_host 
load_modgroups_file
get_common_names
load_ECO_genes
load_NCBI_genes
load_FA
clear_out_spacers
list_tp1_tp2_repeats
list_hi_covg_and_454_repeats
load_repeat_loc_annotation
load_specific_contigs
load_spacers_map
intersection_keys
union_keys
);

@EXPORT_OK = qw (%letter_to_name %name_to_letter $minHitLen);

use strict;
use warnings;

our %letter_to_name = (F=>'FABIAN', I=>'IAN', J=>'JOSH', L=>'LILY', S=>'SEANA');
our %name_to_letter = reverse %letter_to_name;
our $minHitLen = 90;
our %trad_to_eg;

sub look_for_ecogenes_in{
    my $file = $_[0];

    load_EGname_to_Tradname() if scalar keys %Eco::trad_to_eg == 0;

    my %ecogenes;

    open IN, $file or die $!;
    while (<IN>){
    	chomp;
	my @a=split /\t/,$_;
    	
	next if scalar @a == 1;

	my @locis;
	if ($a[1] =~ /,/) {@locis = split /,/,$a[1]}
	else {push @locis, $a[1]}

    	foreach (@locis){
	    $ecogenes{$Eco::trad_to_eg{$_}}=1 if defined $Eco::trad_to_eg{$_};
    	}
    }
    close IN;
    return \%ecogenes;
}

sub load_EGname_to_Tradname{

    open IN, "../tp1/derived_data/EGname_to_Tradname.csv" or die $!;
    
    while (<IN>){
	chomp;
	my ($eg,$trad) = split /\t/,$_;
	$trad_to_eg{$trad}=$eg;
    }
    close IN;
    
}

sub get_coli_name_from_file{
    my $file_name = $_[0];
    chomp $file_name;
    if ($file_name =~ /(Escherichia_coli_.*)\.csv/){
	return $1;
    }
    else{
	die "There's a problem getting the name from $file_name\nQuitting\n";
    }
}

sub make_plasmid_loc_to_locus{
    my %geneToLocName;
    open IN, "derived_data/map_withEcoGene" or die $!;
    while (<IN>){
	#Escherichia_coli_042_uid161985NC_017626336-2798LOCUSTAG: EC042_0001LOCUS: thrASYNS: ECOGENE: EG10998GENEID:
	my (undef,$plsmd,$location,undef,$locus,$syns,$ecogene,undef)=split /\t/,$_;
	$locus =~ s/LOCUS:|\s+//g;
	$syns =~ s/SYNS:|\s+//g;
	
	$geneToLocName{"$plsmd,$location"}=$locus;
	if ($syns ne ''){
	    $geneToLocName{"$plsmd,$location"}.=','.$syns;
	}    
    }
    close IN;
    return \%geneToLocName;
}

sub strip_blat_cols{
# runs through the psl output of blat, and prunes off the stuff we're not interested in. 
# outputs a csv file.

    my @psl_files = @{$_[0]};

    foreach my $file (@psl_files){
	chomp $file;

	open IN, $file or die $!;

	my $outFile = $file;
	$outFile =~ s/\.psl/\.csv/;
	open OUT, ">$outFile" or die $!;

	while (<IN>){
	    chomp;
	    next unless $_ =~ /^\d/;
	    my @a = split /\t/,$_;
	    my $faHeader = $a[13];
	    my @b = split /\|/,$faHeader;
	    my $nc_name = $b[$#b-1];
	    my $loc = $b[$#b];
	    $loc =~ s/://;

	    my $geneLen=$a[10];
	    foreach ($a[$#a-2],$a[$#a-1],$a[$#a]){ # rms trailing commas from some fields where we dont want them
		$_=~ s/,$//;
	    }
	    my @blockSizes = split /,/,$a[$#a-2];
	    my $lens = join ',',@blockSizes;

	    my @starts = split /,/,$a[$#a];
	    my $startAsString = join ',',@starts;
	    my $strand = $a[8];
	    print OUT join "\t",($nc_name,$loc,$geneLen,$lens,$startAsString,$strand);
	    print OUT "\n";
	    
	}
	close IN;
	close OUT;
	# print $file;
	# last;
    }
}

sub union_keys{
    my ($h1,$h2) = ($_[0],$_[1]);
    my %r;
    foreach (keys %{$h1},keys %{$h2} ){
	$r{$_}=1;
    }
    return \%r;
}

sub intersection_keys{
    my ($h1,$h2) = ($_[0],$_[1]);
    my %r;
    foreach (keys %{$h1}){
	$r{$_}=1 if $h2->{$_}
    }
    return \%r;
}

sub load_spacers_map{
    # contig_name   technology   Ian_name=>uniq spacer id
    #>HU4SZHJ01A08CQspacer:1  tp1_454  1_I20=>476
    my $file_name = shift;
    open IN, $file_name or die $!;
    my %ret;
    while (<IN>){
	chomp;
	next if $_ =~ /^#/;
	next if $_ =~ /^\s+$/;
	my ($contig,$num,$tech,$ids) = split /\s+/,$_;

	$ret{$contig.$num}{TECH}=$tech;
	my ($ian_name, $uniq_id) = split /=>/,$ids;
	die "\n-$_-\n ($contig,$num,$tech,$ids) , ($ian_name, $uniq_id)" unless ($ian_name && $uniq_id && $contig && $num && $ids);
	$ret{$contig.$num}{I_NAME}=$ian_name;
	$ret{$contig.$num}{ID}=$uniq_id;
    }
    return \%ret;
}

sub rm_EC{
    my $e = shift;
    $e =~ s/Escherichia_coli_//;
    return $e;
}

sub clear_out_spacers{
    system "rm /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/spacers.fa";# if -e "/home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/spacers.fa";
    system "rm /home/philip/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/bowtie_index/spacers.fa";# if -e "/home/philip/e_reich/tp1_hi_covg/reads/*/*k_57_covg_100/bowtie_index/spacers.fa";
    system "rm /home/philip/e_reich/tp1_454/*bowtie_index/spacers.fa";# if -e "/home/philip/e_reich/tp1_454/*bowtie_index/spacers.fa";
    system "rm /home/philip/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/spacers.fa";# if -e "/home/philip/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/spacers.fa";
    system "rm /home/philip/e_reich/tp1/reads/*_31/bowtie_index/spacers.fa";# if -e "/home/philip/e_reich/tp1/reads/*_31/bowtie_index/spacers.fa";
}

sub load_specific_contigs{

    my %annots = %{$_[0]};
    my %contigs_needed = map {$_ => 1} keys %annots;
    my ($bc,$tp) = ($annots{BC},$annots{TP});

    my $file;
    if ($tp eq 'tp1'){
	$file = "../../$tp/reads/$bc/contigs.fa";
    }
    elsif ($tp eq 'tp2'){
	$file = "../../$tp/reads/$bc/k_31_covg_30/contigs.fa";
    }
    elsif ($tp eq 'tp1_hi_covg'){
	$file = `ls ../../tp1_hi_covg/reads/$bc/*_57_covg_100/contigs.fa`;
	chomp $file;
    }
    elsif ($tp eq 'tp1_454'){
	$file = "../../tp1_454/$bc.fasta";
    }
    else{
	die "$tp <<<\n";
    }
    die "can't find $file \n" if ! -e $file;

    my %contig_to_seq;

    my $need=0;

    open IN, $file or die $!;
    while (<IN>){
	chomp;
	next if $_ =~ /^\s*$/;
	if ($_ =~ /^>(\w+\.?\w*)/){	    

#		print $_,"\n",$1,"\n";

	    if ($contigs_needed{$1}){
		$need = $1;
	    }
	    else{
		$need = 0
	    }
	}
	elsif($need){
	    $contig_to_seq{$need} .=$_;
	}
    }
    close IN;
    return \%contig_to_seq;

}


sub load_repeat_loc_annotation{
    my $file = shift;
    chomp $file;
    my $bc = $1 if $file =~ /reads\/(\w+)\//;
    $bc = $1 if $file =~ /tp1_454\/(\w+)bowtie_index/;
    my %reps;
    open IN, $file or die $!;
    while (<IN>){
	# cointig name                      offset seq                        olap? tie breaker! strand timepoint
	# NODE_9909_length_60_cov_48.633335 0  CGGTTTATCCCCGCTGACGCGGGGAACAC   0   0  + tp1_454
	# NODE_9909_length_60_cov_48.633335 1  GGTTTATCCCCGCTGGCGCGGGGAACAC    0   1  + tp1_454
	chomp;
	my ($ctg_name,$loc,$seq,$is_olap,$tb,$strand,$tp) = split /\t/,$_;
	# print $file,":",$_,"\n" if $ctg_name eq 'GCGGTTTATCCCCGCTGGCGCGGGGAACTC'; #name eq 'NODE_741_length_58_cov_9.758620';
	$reps{TP}=$tp;
	$reps{BC}=$bc;
	my %r;
	$r{FILE}=$file;
	$r{TP}=$tp;
	# $r{BC}=$bc;
	$r{SEQ}=$seq;
	$r{OLAPS}=$is_olap;
	$r{DOM}=$tb;
	$r{STRAND}=$strand;
	$r{LOC}=$loc;
	push @{$reps{$ctg_name}},\%r;
    }
    close IN or warn;
    return \%reps;
}

sub list_hi_covg_and_454_repeats{
    my %name_to_loc;
    my @reps_454 = `ls /home/philip/e_reich/tp1_454/*bowtie_index/rep_locs.out`;
    foreach my $loc (@reps_454){
	my $id = $1 if $loc =~ /\/(\w+)bowtie_index/;
	$name_to_loc{'tp1_454_'.$id}=$loc;
    }

    my @reps1_hi_covg = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_57_covg_100/bowtie_index/rep_locs.out`;
    foreach my $loc (@reps1_hi_covg){
	my $id = $1.'_'.$2 if $loc =~ /\/(\w+)\/(\w+)k_57/;
	$name_to_loc{'tp1_hi_covg_'.$id}=$loc;
    }
    
    return \%name_to_loc;
}

sub list_tp1_tp2_repeats{
    my %mgs = %{load_modgroups_file()};
    my %name_to_rep_file;
    foreach my $name (keys %mgs){
	my $file ='';
	if ($mgs{$name}{TP} == 1){
	    $file = "/home/philip/e_reich/tp1/reads/$mgs{$name}{BC}_31/bowtie_index/rep_locs.out";
	}
	elsif  ($mgs{$name}{TP} == 2){
	    $file = "/home/philip/e_reich/tp2/reads/$mgs{$name}{BC}/k_31_covg_30/bowtie_index/rep_locs.out";
	}
	else { die "$mgs{$name}{TP} huh?" }
	die "Can't find file for $name, ($file)\n" unless -e $file;
	$name_to_rep_file{$name}=$file;
    }
    return \%name_to_rep_file;

    # my @reps1_hi_covg_ds = `ls /home/philip/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/rep_locs.out`;
    # return [(@reps_454, @reps1_hi_covg_ds, @reps1_hi_covg, @repeatFiles1 , @repeatFiles2)];
}

sub load_NCBI_genes{
    my $file = shift;
    open IN, $file or die $!;
    my %h;
    while (<IN>){
	chomp;
	my ($g,undef) = split "\t",$_;
	next if $g eq '';
	$h{$g}=1;
    }
    close IN;
    return \%h;
}

sub load_ECO_genes{
    my $file = shift;
    open IN, $file or die $!;
    my %h;
    while (<IN>){
	chomp;
	my $g = $_;
	next if $g eq '';
	$h{$g}=1;
    }
    close IN;
    return \%h;
}


sub load_FA{
    my $file = shift;
    chomp $file;
    open IN, $file  or die $!;
    my $head='';
    my $line='';
    my %h;
    while (<IN>){
	chomp;
	next if $_ =~ /^\s?$/;
	if ($_=~ /^>/){
	    $h{$head}=$line unless $head eq '';
            $head = $_;
	    $line='';
	}
        else{
            $line.=$_;
	}
    }
    close IN;
    $h{$head}=$line unless $head eq '';    
    return \%h;
}

sub get_common_names{
    my $file = shift;
    open IN, $file or die $!;
    my %h;
    while (<IN>){
	chomp;
	my (undef,$cn)=split /\t/;
	next if $cn eq '';
	$h{$cn}=1;
    }
    close IN;
    return \%h;
}

sub load_modgroups_file{
    open MG, '../lib/modgroups11272013_with_philip_strain_call.txt' or die $!;
#Name   Group   tp      isolate bc      phylogroup strain

    my %h;
    while (<MG>){
	chomp;
	my ($name,$group,$tp,$isolate,$bc,$phylogroup,$strain) = split /\t/;
        foreach ($name,$group,$tp,$isolate,$bc,$phylogroup,$strain){
            $_=~ s/\s+//g;
	    die "Missing info for $name,$group,$tp,$isolate,$bc,$phylogroup \n" if $_ eq '';
        }
	my $ind_let = substr($isolate,0,1); # get the first letter;
	my $indiv = $letter_to_name{$ind_let};
	die "Can't look up indiv for $isolate\n" if !defined $indiv;

	$h{$name}{GROUP}=$group;
	$h{$name}{TP}=$tp;
	$h{$name}{ISOLATE}=$isolate;
	$h{$name}{BC}=$bc;
	$h{$name}{PHYLOGROUP}=$phylogroup;
	$h{$name}{STRAIN}=$strain;
    }
    close MG;
    return \%h;
}

sub load_plate_letters_to_int{

    open LI, 'modgroups11272013.txt' or die 'can\'t open file '.$!;
    my %bc_to_indiv;
    while (<LI>){
	#Name Group tp isolate bc      phylogroup
        #1_F1 1     1  F1      AGCAGT  B1

        chomp;
        next if $_ =~ /^#/;
	my ($name,$group,$tp,$isolate,$bc,$phylogroup) = split /\t/;
        foreach ($name,$group,$tp,$isolate,$bc,$phylogroup){
            $_=~ s/\s+//g;
        }
	my $ind_let = substr($isolate,0,1); # get the first letter;
	my $indiv = $letter_to_name{$ind_let};
	die "Can't look up indiv for $isolate\n" if !defined $indiv;
#	 = $indiv'.individual';
	if ($tp == 1){	$bc_to_indiv{$bc}{T1}=$indiv  }
	elsif ($tp == 2){  $bc_to_indiv{$bc}{T2}=$indiv  } 
	else {die "No time info for $_\n";}
    }
    close LI;
    return \%bc_to_indiv;
}

sub load_sample_to_host{

}

sub load_sample_to_host_ori{
    my $tp = shift;
    my $file;
    if ($tp eq 'tp2'){     $file = '../tp2/derived_data/top_picks_not_merged_with_Ian_work'  }
    elsif ($tp eq 'tp1'){  $file = '../tp1/derived_data/top_picks_merged_with_Ian_work'  }
    else { die "this is not how you use load_sample_to_host, need tp\n" }

    open IN, $file or die 'can\'t open file '.$!;
    my %hosts;

    while (<IN>){
        chomp;
        next if $_ =~ /^barcode/;

        my ($bc,$strain,undef,undef,$host) = split /\t/;

        foreach ($bc,$strain,$host){
            $_=~s/\s+//g;
        }

        next unless $strain eq 'Escherichia_coli_UTI89_uid58541';
        $hosts{$bc}=$host;
    }
    close IN;
#    print values %hosts;
    return \%hosts;
}

sub load_ECO_genes_by_bc{
    open IN, $_[0] or die 'can\'t open file '.$!;
    my %genes;

    while (<IN>){
        chomp;
        next if $_ =~ /^\s+$/;
	$genes{$_}=1;
    }
    close IN;
    return \%genes
}

1;

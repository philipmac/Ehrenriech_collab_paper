use warnings;
use strict;

# look up the repeats in the contigs...

# bowtie [options]* <ebwt> {-1 <m1> -2 <m2> | --12 <r> | <s>} [<hit>]
# bowtie -f -v 0 -a -p 4  < 0 missmatch because thes are contigs 
# -f => fasta input
# -v report end-to-end hits w/ <=v mismatches
# -a report all alignments per read
# -p 4 num cores to use. 

# Spacerdatabase_Ecoli.txt

my $rep_db = '~/e_reich/crispr/data/repeat_database_Ecoli.txt';

# time point 1 454 contigs
my @indexes = `ls ~/e_reich/tp1_454/*bowtie_index/*bwt`;

# hi covg, tp1 stuff.
push @indexes, `ls ~/e_reich/tp1_hi_covg/reads/*/*_57_covg_100/bowtie_index/*bwt`;

# # *down sampled* hi covg, tp1 stuff.
push @indexes, `ls ~/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/bowtie_index/*bwt`;

# # normal covg, tp1
push @indexes, `ls ~/e_reich/tp1/reads/*_31/bowtie_index/*bwt`;

# # normal covg, tp2
push @indexes, `ls ~/e_reich/tp2/reads/*/k_31_covg_30/bowtie_index/*bwt`;

lookup(\@indexes);


sub lookup{
    my @a = @{$_[0]};
    foreach my $index(@a){
	chomp $index;

#	next unless $index =~ s/:$//;

#	next if $index =~ /seqs/;
	$index =~ s/\.\d+\.ebwt//;
	$index =~ s/\.rev//;
	my $out = $index; 
	$out =~ s/\/bowtie_index//;
	if ($out =~ /454/){
	    $out =~ s/\w+bowtie_index\///;
	}

	$out .='/bwt_off_by_three_e_coli.out';
	next if -e $out;
# 	my @a = split  '/', $index;
# #	$index .= '/'.$a[$#a];

	system "bowtie --quiet  -f -v 3 -a -p 4 $index $rep_db $out";
	#system "\n";
    }    
}


# time point 1
# my @indexes = `ls ~/e_reich/tp1/reads/`;

# foreach my $index(@indexes){
#     chomp $index;
#     next if $index =~ /seqs/;
#     system "bowtie  --quiet -f -v 0 -a -p 4 ~/e_reich/tp1/reads/$index/bowtie_index/bowtie_index ~/e_reich/crispr/data/repeat_database_Ecoli.txt ~/e_reich/tp1/reads/$index/bwt_exact_e_coli.out \n";
# }
   

# time point 2
# 
# foreach my $index(@indexes){
#     chomp $index;
#     next if $index =~ /seqs/;

#     system "bowtie   --quiet  -f -v 1 -a -p 4 ~/e_reich/tp2/reads/$index/k_31_covg_30/bowtie_index/bowtie_index ~/e_reich/crispr/data/repeat_database_Ecoli.txt ~/e_reich/tp2/reads/$index/k_31_covg_30/bwt_exact_e_coli.out \n";
# }
   

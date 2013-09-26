use strict;
use warnings;

my @contigs = `ls ~/e_reich/tp1/reads/*_31/contigs.fa`;
indexCtgs(\@contigs);

@contigs = `ls ~/e_reich/tp2/reads/*/k_31_covg_30/contigs.fa`;
indexCtgs(\@contigs);

@contigs = `ls ~/e_reich/tp1_hi_covg/reads/*/*_57_covg_100/contigs.fa`;
indexCtgs(\@contigs);

@contigs = `ls ~/e_reich/tp1_hi_covg/reads/*/*_ds_4k_31_covg_30/contigs.fa`;
indexCtgs(\@contigs);

@contigs = `ls ~/e_reich/tp1_454/*fasta`;
indexCtgs(\@contigs);

sub indexCtgs{
    foreach my $contig (@{$_[0]}){
	chomp $contig;
	my $dir = $contig;   
	$dir =~ s/contigs\.fa/bowtie_index/;
	# add a little exception in here for the straight 454 reads...
	$dir =~ s/\.fasta$/bowtie_index/;

	next if -e $dir;
	system "mkdir $dir" unless -d $dir;
	system "bowtie-build -q $contig $dir";
	system "mv $dir.* $dir";
    }
}


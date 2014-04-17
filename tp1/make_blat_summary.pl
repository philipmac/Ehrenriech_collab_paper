use warnings;
use strict;
use Eco;

my @psl_files = `ls ../../tp1/reads/*_31/blat/Escherichia_coli_*psl`;

strip_blat_cols(\@psl_files);

print "blat parse done...\n";

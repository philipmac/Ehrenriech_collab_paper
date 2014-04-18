use warnings;
use strict;
use Eco;

my @psl_files = `ls ../../tp2/reads/*/k_31_covg_30/blat/*.psl`;

strip_blat_cols(\@psl_files);

print "blat parse done...\n";

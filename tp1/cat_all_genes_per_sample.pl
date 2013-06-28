# this just joins up files so that mult strain hits are all in same file. 
# note the genes_hit file is any hit, regardless of size, 
# we'll filter them later.

use strict;
use warnings;

my @samples = `ls ../ecolireads`;
foreach my $sample (@samples){
    next unless $sample =~ /_31/;
    chomp $sample;
    system "cat ../ecolireads/$sample/blat/gene_calls/Esch* > ../ecolireads/$sample/blat/gene_calls/all_strains.genes_hit";
}

# foreach my $file (@files){
#     chomp $file;
#     system "cat ../ecolireads/$file/blat/*.genes_hit > ";
#     last;
# }
 

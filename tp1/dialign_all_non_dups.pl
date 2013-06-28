use warnings;
use strict;

my @files = `ls tags/non_id/comp/*`;
foreach my $file (@files){
    chomp $file;
    next if (-s $file == 0);
    system "dialign2-2 -nt $file";

}
    

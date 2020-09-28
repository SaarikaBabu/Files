use warnings;
use strict;

my $filename  = "/home/saarika/Documents/Textfile.txt";
my $content;
open(FH, '<', $filename);
$content .= $_ while (<FH>);
close FH;

my $txns = '';
if ($content =~ /CREDIT\s+SUMMARY.*?Date.*?Transaction\s+Details.*?Points\s+amount\s+(.*?)\s+International\s+Spends/is) {
    $txns = $1;
}
print $txns."\n";
my @array = split ('\n', $txns);
foreach my $row (scalar @array) 
{
    print "$row\n";
}

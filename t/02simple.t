#!/usr/bin/perl 

print "1..$tests\n";

use Finance::YahooQuote;
$Finance::YahooQuote::TIMEOUT = 60;

@quote = getonequote "IBM"; 

print "ok 1\n" if $quote[1] eq "INTL BUS MACHINE";

BEGIN{$tests = 1;}
exit(0);

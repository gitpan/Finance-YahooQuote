# perl -w
#
#    Copyright (C) 1998-2000, Dj Padzensky <djpadz@padz.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

package Finance::YahooQuote;
require 5.000;

require Exporter;
use strict;
use vars qw($VERSION @EXPORT @ISA $QURL $TIMEOUT);

use LWP::UserAgent;
use HTTP::Request::Common;

$VERSION = '0.15';
$QURL = ("http://quote.yahoo.com/d?f=snl1d1t1c1p2va2bapomwerr1dyj1x&s=");
@ISA = qw(Exporter);
@EXPORT = qw(&getquote &getonequote);
undef $TIMEOUT;

sub getquote {
    my @symbols = @_;
    my($x,@q,@qr,$ua,$url);
    $x = $";
    $" = "+";
    $url = $QURL."@symbols";
    $" = $x;
    $ua = LWP::UserAgent->new;
    $ua->timeout($TIMEOUT) if defined $TIMEOUT;
    $ua->env_proxy();
    foreach (split('\015?\012',$ua->request(GET $url)->content)) {
	@q = grep { s/^"?(.*?)\s*"?\s*$/$1/; } split(',');
	push(@qr,[@q]);
    }
    return wantarray() ? @qr : \@qr;
}

# Input: A single stock symbol
# Output: An array, containing the list elements mentioned above.

sub getonequote {
    my @x;
    @x = &getquote($_[0]);
    return wantarray() ? @{$x[0]} : \@{$x[0]} if @x;
}

1;

__END__

=head1 NAME

Finance::YahooQuote - Get a stock quote from Yahoo!

=head1 SYNOPSIS

  use Finance::YahooQuote;
  $Finance::YahooQuote::TIMEOUT = 60;
  @quote = getonequote $symbol;	# Get a quote for a single symbol
  @quotes = getquote @symbols;	# Get quotes for a bunch of symbols

=head1 DESCRIPTION

This module gets stock quotes from Yahoo! Finance.  The B<getonequote>
function will return a quote for a single stock symbol, while the
B<getquote> function will return a quote for each of the stock symbols
passed to it.  The return value of B<getonequote> is an array, with
the following elements:

    0 Symbol
    1 Company Name
    2 Last Price
    3 Last Trade Date
    4 Last Trade Time
    5 Change
    6 Percent Change
    7 Volume
    8 Average Daily Vol
    9 Bid
    10 Ask
    11 Previous Close
    12 Today's Open
    13 Day's Range
    14 52-Week Range
    15 Earnings per Share
    16 P/E Ratio
    17 Dividend Pay Date
    18 Dividend per Share
    19 Dividend Yield
    20 Market Capitalization
    21 Stock Exchange

The B<getquote> function returns an array of pointers to arrays with
the above structure.

You may optionally override the default LWP timeout of 180 seconds by setting
$Finance::YahooQuote::TIMEOUT to your preferred value.

=head1 FAQ

If there's one question I get asked over and over again, it's how did
I figure out the format string?  Having typed the answer in
innumerable emails, I figure sticking it directly into the man page
might help save my fingers a bit...

If you have a My Yahoo! (http://my.yahoo.com) account, go to the
following URL:

    http://edit.my.yahoo.com/config/edit_pfview?.vk=v1

Viewing the source of this page, you'll come across the section that
defines the menus that let you select which elements go into a
particular view.  The <option> values are the strings that pick up
the information described in the menu item.  For example, Symbol
refers to the string "s" and name refers to the string "l".  Using
"sl" as the format string, we would get the symbol followed by the
name of the security.

If you have questions regarding this, play around with $QURL, changing
the value of the f parameter.

=head1 COPYRIGHT

Copyright 1998, Dj Padzensky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

The information that you obtain with this library may be copyrighted
by Yahoo! Inc., and is governed by their usage license.  See
http://www.yahoo.com/docs/info/gen_disclaimer.html for more
information.

=head1 AUTHOR

Dj Padzensky (C<djpadz@padz.net>), PadzNet, Inc.

The Finance::YahooQuote home page can be found at
http://www.padz.net/~djpadz/YahooQuote/

=cut

# perl -w
#
#    Copyright (C) 1998-2002, Dj Padzensky <djpadz@padz.net>
#    Copyright (C) 2002-2003  Dirk Eddelbuettel <edd@debian.org>
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
# $Id: YahooQuote.pm,v 1.4 2003/04/19 22:17:40 edd Exp $

package Finance::YahooQuote;
require 5.005;

require Exporter;
use strict;
use vars qw($VERSION @EXPORT @ISA $QURL $TIMEOUT 
	    $PROXY $PROXYUSER $PROXYPASSWD);

use HTTP::Request::Common;
use Text::ParseWords;

$VERSION = '0.19';
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
  $ua = RequestAgent->new;
  $ua->env_proxy;		# proxy settings from *_proxy env. variables.
  $ua->proxy('http', $PROXY) if defined $PROXY;
  $ua->timeout($TIMEOUT) if defined $TIMEOUT;
  foreach (split('\015?\012',$ua->request(GET $url)->content)) {
    @q = quotewords(',',0,$_);
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

BEGIN {				# Local variant of LWP::UserAgent that 
  use LWP;			# checks for user/password if document 
  package RequestAgent;		# this code taken from lwp-request, see
  no strict 'vars';		# the various LWP manual pages
  @ISA = qw(LWP::UserAgent);

  sub new { 
    my $self = LWP::UserAgent::new(@_);
    $self->agent("Finance-YahooQuote/0.18");
    $self;
  }

  sub get_basic_credentials {
    my $self = @_;
    if (defined($PROXYUSER) and defined($PROXYPASSWD) and
 	$PROXYUSER ne "" and $PROXYPASSWD ne "") {
      return ($PROXYUSER, $PROXYPASSWD);
    } else {
      return (undef, undef)
    }
  }
}

1;

__END__

=head1 NAME

Finance::YahooQuote - Get stock quotes from Yahoo! Finance

=head1 SYNOPSIS

  use Finance::YahooQuote;
  # setting TIMEOUT and PROXY is optional
  $Finance::YahooQuote::TIMEOUT = 60;
  $Finance::YahooQuote::PROXY = "http://some.where.net:8080";
  @quote = getonequote $symbol;	# Get a quote for a single symbol
  @quotes = getquote @symbols;	# Get quotes for a bunch of symbols

=head1 DESCRIPTION

This module gets stock quotes from Yahoo! Finance.  The B<getonequote>
function will return a quote for a single stock symbol, while the
B<getquote> function will return a quote for each of the stock symbols
passed to it.  The download operation is efficient: only one request
is made even if several symbols are requested at once. The return 
value of B<getonequote> is an array, with the following elements:

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

Beyond stock quotes, B<Finance::YahooQuote> can also obtain quotes
for currencies (from the Philadephia exchange), US mutual funds, options 
on US stocks, several precious metals and quite possibly more; see the
Yahoo! Finance website for full information. B<Finance::YahooQuote>
can be used for stocks from the USA, Canada, various European
exchanges, various Asian exchanges (Singapore, Taiwan, HongKong, Kuala
Lumpur, ...) Australia and New Zealand. It should work for other
markets supported by Yahoo.

You may optionally override the default LWP timeout of 180 seconds by setting
$Finance::YahooQuote::TIMEOUT to your preferred value.

You may also provide a proxy (for the required http connection) by using
the variable $Finance::YahooQuote::PROXY. Furthermore, authentication-based 
proxies can be used by setting the proxy user and password via the variables
$Finance::YahooQuote::PROXYUSER and $Finance::YahooQuote::PROXYPASSWD.

Two example scripts are provided to help with the mapping a stock symbols as
well as with Yahoo! Finance server codes.

=head1 FAQs

=head2 How can one figure out the format string?  

Provided a My Yahoo! (http://my.yahoo.com) account, go to the
following URL:

    http://edit.my.yahoo.com/config/edit_pfview?.vk=v1

Viewing the source of this page, you will come across the section that
defines the menus that let you select which elements go into a
particular view.  The <option> values are the strings that pick up
the information described in the menu item.  For example, Symbol
refers to the string "s" and name refers to the string "l".  Using
"sl" as the format string, we would get the symbol followed by the
name of the security.

The example script I<examine_server.sh> shows this in some more detail
and downloads example .csv files using B<GNU wget>.

=head2 What about different stock symbols for the same corporation?

This can be issue. For the first few years, Yahoo! Finance's servers 
appeared to be cover their respective local markets. E.g., the UK-based 
servers provided quotes for Europe, the Australian one for the Australia
and New Zealand and so on.  Hence, one needed to branch and bound code
and map symbols to their region's servers.

It now appears that this is no longer required, which is good news as it 
simplifies coding. However, some old symbols are no longer supported --
yet other, and supported, codes exist for the same company.  For example,
German stocks used to quoted in terms or their cusip-like 'WKN'. The
main server does not support these, but does support newer, acronym-based
symbols.  The example script examine_server.sh helps in finding the mapping
as e.g. from 555750.F to DTEGN.F for Deutsche Telekom. 

=head1 COPYRIGHT

Copyright 1998, 1999, 2000, 2001, 2002 Dj Padzensky
Copyright 2002 Dirk Eddelbuettel

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

The information that you obtain with this library may be copyrighted
by Yahoo! Inc., and is governed by their usage license.  See
http://www.yahoo.com/docs/info/gen_disclaimer.html for more
information.

=head1 AUTHOR

Dj Padzensky (C<djpadz@padz.net>), PadzNet, Inc., wrote the original 
version. Dirk Eddelbuettel (C<edd@debian.org>) provided some extensions.

=head1 SEE ALSO

The B<Finance::YahooQuote> home pages are found at
http://www.padz.net/~djpadz/YahooQuote/ and
http://dirk.eddelbuettel.com/code/yahooquote.html.

The B<smtm> (Show Me The Money) program uses Finance::YahooQuote for a
customisable stock/portfolio ticker and chart display, see 
http://dirk.eddelbuettel.com/code/smtm.html for more.  The B<beancounter>
program uses it to store quotes in a SQL database, see
http://dirk.eddelbuettel.com/code/beancounter.html.

=cut


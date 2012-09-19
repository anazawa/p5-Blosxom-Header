use strict;
use warnings;
use Benchmark qw/cmpthese/;
use CGI::Util 'expires';
use HTTP::Date;

my $now = time;

cmpthese(-1, {
    'CGI::Util::expires()'   => sub { my $date = expires( $now )  },
    'HTTP::Date::time2str()' => sub { my $date = time2str( $now ) },
});

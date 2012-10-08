use strict;
use warnings;
use Blosxom::Header;
use Test::More tests => 2;

my %header;
$blosxom::header = \%header;
my $header = Blosxom::Header->instance;

my $now = 1341637509;

subtest 'date()' => sub {
    %header = ();
    is $header->date, undef;
    $header->date( $now );
    is $header->date, $now;
    is $header->{Date}, 'Sat, 07 Jul 2012 05:05:09 GMT';
};

subtest 'expires()' => sub {
    %header = ();
    is $header->expires, undef;

    $header->expires( $now );
    is $header->expires, $now, 'get expires()';
    is $header->{Expires}, 'Sat, 07 Jul 2012 05:05:09 GMT';

    $header->expires( 'Sat, 07 Jul 2012 05:05:10 GMT' );
    is $header->expires, $now+1, 'get expires()';
    is $header->{Expires}, 'Sat, 07 Jul 2012 05:05:10 GMT';
};

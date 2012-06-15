use strict;
use Test::More tests => 6;

BEGIN {
    use_ok 'Blosxom::Header', qw( $Header header_get );
}

can_ok __PACKAGE__, 'header_get';

ok( Blosxom::Header->has_instance );
ok $Header;
is $Header, Blosxom::Header->has_instance;

my $h = Blosxom::Header->instance;
is $h, $Header;


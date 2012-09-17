use strict;
use warnings;
use Test::Exception;
use Test::More tests => 10;

BEGIN {
    my @functions = qw(
        header_get    header_set  header_exists
        header_delete header_iter
    );

    use_ok 'Blosxom::Header', @functions;
    can_ok __PACKAGE__, @functions;
}

# initialize
my %header;
$blosxom::header = \%header;

is header_get( 'Content-Type' ), 'text/html; charset=ISO-8859-1';
is header_get( 'Status' ), undef;

ok header_exists( 'Content-Type' );
ok !header_exists( 'Status' );

header_set( Status => '304 Not Modified' );
is_deeply \%header, { -status => '304 Not Modified' };

is header_delete( 'Status' ), '304 Not Modified';
is_deeply \%header, {};

my @got;
header_iter sub {
    my ( $field, $value ) = @_;
    push @got, $field, $value;
};

my @expected = ( 'Content-Type', 'text/html; charset=ISO-8859-1' );

is_deeply \@got, \@expected;

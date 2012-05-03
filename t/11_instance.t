use strict;
use Blosxom::Header;
use Test::More;

{
    package blosxom;
    our $header;
}

eval { Blosxom::Header->instance };
like $@, qr{^\$blosxom::header hasn't been initialized yet};

# initialize
$blosxom::header = { -cookie => ['foo', 'bar'] };

my $header = Blosxom::Header->instance;
isa_ok $header, 'Blosxom::Header';
can_ok $header, qw(
    exists clear delete get set push_cookie push_p3p
    attachment charset cookie expires nph p3p status target type
);

is $header->get( 'cookie' ), 'foo', 'get() in scalar context';

{
    my @got = $header->get( 'cookie' );
    my @expected = qw/foo bar/;
    is_deeply \@got, \@expected, 'get() in list context';
}

$header->set(
    -foo => 'bar',
    -bar => 'baz',
    -baz => 'qux',
);

{
    my @got = $header->delete( qw/foo bar/ );
    my @expected = qw/bar baz/;
    is_deeply \@got, \@expected, 'delete() multiple elements';
}

eval { $header->set( 'foo' ) };
like $@, qr{^Odd number of elements are passed to set()};

done_testing;

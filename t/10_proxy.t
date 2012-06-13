use strict;
use Blosxom::Header::Proxy;
use Test::Exception;
use Test::More tests => 2;

{
    package blosxom;
    our $header;
}

subtest 'basic' => sub {
    my $proxy = tie my %proxy => 'Blosxom::Header::Proxy';
    isa_ok $proxy, 'Blosxom::Header::Proxy';
    can_ok $proxy, qw(
        FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
        header
    );

    ok !%proxy, 'not initialized yet';
    my $expected = qr/^\$blosxom::header hasn't been initialized yet/;
    throws_ok { $proxy->header } $expected, 'header() throws an exception';

    local $blosxom::header = {};
    ok %proxy, 'already initialized';
    is $proxy->header, $blosxom::header,
        'header() returns the same reference as $blosxom::header';

    ok $proxy->_is_normalized( 'foo' );

    is $proxy->_normalize_field_name( 'foo' ), 'foo';
};

subtest 'insensitive hash' => sub {
    local $blosxom::header = { foo => 'bar' };
    my $callback = sub { lc shift };
    my $proxy = tie my %proxy => 'Blosxom::Header::Proxy', $callback;

    ok $proxy->_is_normalized( 'foo' );
    ok !$proxy->_is_normalized( 'Foo' );

    is $proxy->_normalize_field_name( 'Foo' ), 'foo';

    ok exists $proxy{Foo}, 'EXISTS() should return true';
    ok !exists $proxy{Bar}, 'EXISTS() should return false';

    is $proxy{Foo}, 'bar', 'FETCH()';
    is $proxy{Bar}, undef, 'FETCH() undef';

    $proxy{Bar} = 'baz';
    is $proxy->header->{bar}, 'baz', 'STORE()';

    is_deeply [ sort keys %proxy   ], [ 'bar', 'foo' ], 'keys()';
    is_deeply [ sort values %proxy ], [ 'bar', 'baz' ], 'values()';

    is delete $proxy{Foo}, 'bar';
    is_deeply $proxy->header, { bar => 'baz' }, 'DELETE()';

    %proxy = ();
    is_deeply $proxy->header, {}, 'CLEAR()';
};

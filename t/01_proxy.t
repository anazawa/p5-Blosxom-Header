use strict;
use Blosxom::Header::Proxy;
use Test::More tests => 4;
use Test::Exception;

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
};

subtest 'SCALAR()' => sub {
    tie my %proxy => 'Blosxom::Header::Proxy';
    ok !%proxy, 'not initialized yet';
    local $blosxom::header = {};
    ok %proxy, 'already initialized';
};

subtest 'header()' => sub {
    my $proxy = tie my %proxy => 'Blosxom::Header::Proxy';
    my $expected = qr/^\$blosxom::header hasn't been initialized yet/;
    throws_ok { $proxy->header } $expected;
    local $blosxom::header = {};
    is $proxy->header, $blosxom::header;
};

subtest 'insensitive hash' => sub {
    local $blosxom::header = { foo => 'bar' };
    my $callback = sub { lc shift };
    tie my %proxy => 'Blosxom::Header::Proxy', $callback;

    is $proxy{Foo}, 'bar', 'FETCH()';

    $proxy{Bar} = 'baz';
    is $blosxom::header->{bar}, 'baz', 'STORE()';

    is_deeply [ sort keys %proxy   ], [ 'bar', 'foo' ], 'keys()';
    is_deeply [ sort values %proxy ], [ 'bar', 'baz' ], 'values()';

    is delete $proxy{Foo}, 'bar';
    is_deeply $blosxom::header, { bar => 'baz' }, 'DELETE()';

    %proxy = ();
    is_deeply $blosxom::header, {}, 'CLEAR()';
};

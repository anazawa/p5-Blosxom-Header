use strict;
use Blosxom::Header::Proxy;
use Test::More tests => 1;

subtest 'basic' => sub {
    my %foo = ( foo => 'bar' );

    tie my %proxy => 'Blosxom::Header::Proxy', (
        hashref  => \%foo,
        callback => sub { lc shift },
    );

    is $proxy{Foo}, 'bar', 'FETCH()';

    $proxy{Bar} = 'baz';
    is $foo{bar}, 'baz', 'STORE()';

    is_deeply [ sort keys %proxy   ], [ 'bar', 'foo' ], 'keys()';
    is_deeply [ sort values %proxy ], [ 'bar', 'baz' ], 'values()';

    delete $proxy{Foo};
    is_deeply \%foo, { bar => 'baz' }, 'DELETE()';

    %proxy = ();
    is_deeply \%foo, {}, 'CLEAR()';
};

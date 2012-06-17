use strict;
use Blosxom::Header::Proxy;
use Test::Exception;
use Test::More tests => 8;

{
    package blosxom;
    our $header;
}

my $proxy = tie my %proxy => 'Blosxom::Header::Proxy';

subtest 'basic' => sub {
    isa_ok $proxy, 'Blosxom::Header::Proxy';
    can_ok $proxy, qw(
        FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
        header is_initialized
    );
};

subtest 'is_initialized()' => sub {
    local $blosxom::header;
    ok !$proxy->is_initialized, 'should return false';

    $blosxom::header = {};
    ok $proxy->is_initialized, 'should return true';
};

subtest 'header()' => sub {
    local $blosxom::header;
    my $expected = qr/^\$blosxom::header hasn't been initialized yet/;
    throws_ok { $proxy->header } $expected, 'header() throws an exception';

    $blosxom::header = {};
    is $proxy->header, $blosxom::header,
        'header() returns the same reference as $blosxom::header';
};

#subtest 'insensitive hash' => sub {
#    local $blosxom::header = { foo => 'bar' };
#    my $callback = sub { lc shift };
#    my $proxy = tie my %proxy => 'Blosxom::Header::Proxy', $callback;

#    ok exists $proxy{Foo}, 'EXISTS() should return true';
#    ok !exists $proxy{Bar}, 'EXISTS() should return false';

#    is $proxy{Foo}, 'bar', 'FETCH()';
#    is $proxy{Bar}, undef, 'FETCH() undef';

#    $proxy{Bar} = 'baz';
#    is $proxy->header->{bar}, 'baz', 'STORE()';

#    is_deeply [ sort keys %proxy   ], [ 'bar', 'foo' ], 'keys()';
#    is_deeply [ sort values %proxy ], [ 'bar', 'baz' ], 'values()';

#    is delete $proxy{Foo}, 'bar';
#    is_deeply $proxy->header, { bar => 'baz' }, 'DELETE()';

#    %proxy = ();
#    is_deeply $proxy->header, { -type => q{} }, 'CLEAR()';
#};

subtest 'SCALAR()' => sub {
    local $blosxom::header = {};
    ok %proxy;

    $blosxom::header = { -type => q{} };
    ok !%proxy;

    $blosxom::header = { -foo => 'bar' };
    ok %proxy;
};

subtest 'CLEAR()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    %proxy = ();
    is_deeply $blosxom::header, { -type => q{} };
};

subtest 'EXISTS()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    ok exists $proxy{Foo};
    ok !exists $proxy{Bar};

    $blosxom::header = { -type => q{} };
    ok !exists $proxy{Content_Type};

    $blosxom::header = {};
    ok exists $proxy{Content_Type};
};

subtest 'DELETE()' => sub {
    local $blosxom::header = { -foo => 'bar', -bar => 'baz' };
    is delete $proxy{Foo}, 'bar';
    is_deeply $blosxom::header, { -bar => 'baz' };

    $blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    delete $proxy{Content_Type}; # text/plain; charset=utf-8
    is_deeply $blosxom::header, { -type => q{} };
};

subtest 'FETCH()' => sub {
    local $blosxom::header = {};
    is $proxy{Content_Type}, 'text/html; charset=ISO-8859-1';

    $blosxom::header = { -type => 'text/plain' };
    is $proxy{Content_Type}, 'text/plain; charset=ISO-8859-1';

    $blosxom::header = { -charset => 'utf-8' };
    is $proxy{Content_Type}, 'text/html; charset=utf-8';

    $blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    is $proxy{Content_Type}, 'text/plain; charset=utf-8';

    $blosxom::header = { -type => q{} };
    is $proxy{Content_Type}, undef;

    $blosxom::header = { -type => q{}, -charset => 'utf-8' };
    is $proxy{Content_Type}, undef;

    $blosxom::header = { -type => 'text/plain; charset=EUC-JP' };
    is $proxy{Content_Type}, 'text/plain; charset=EUC-JP';

    $blosxom::header = {
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    };
    is $proxy{Content_Type}, 'text/plain; charset=euc-jp';

    $blosxom::header = { -charset => q{} };
    is $proxy{Content_Type}, 'text/html';
};

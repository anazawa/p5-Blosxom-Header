use strict;
use warnings;
use Blosxom::Header::Adapter;
use Test::More tests => 17;
use Test::Warn;

can_ok 'Blosxom::Header::Adapter', qw(
    FETCH STORE DELETE EXISTS CLEAR SCALAR DESTROY
    _normalize _denormalize
    _date_header_is_fixed
    field_names
    p3p_tags push_p3p_tags
    nph attachment
    expires
    header
);

my %adaptee;
my $adapter = tie my %adapter, 'Blosxom::Header::Adapter', \%adaptee;
ok $adapter->isa( 'Blosxom::Header::Adapter' );

# SCALAR
%adaptee = ();
ok %adapter;
%adaptee = ( -type => q{} );
ok !%adapter;

# CLEAR
%adaptee = ();
%adapter = ();
is_deeply \%adaptee, { -type => q{} };

# EXISTS
%adaptee = ( -foo => 'bar', -bar => q{} );
ok exists $adapter{Foo};
ok !exists $adapter{Bar};
ok !exists $adapter{Baz};

# DELETE
%adaptee = ( -foo => 'bar', -bar => 'baz' );
is delete $adapter{Foo}, 'bar';
is_deeply \%adaptee, { -bar => 'baz' };

# FETCH
%adaptee = ( -foo => 'bar' );
is $adapter{Foo}, 'bar';
is $adapter{Bar}, undef;

# STORE
%adaptee = ();
$adapter{Foo} = 'bar';
is_deeply \%adaptee, { -foo => 'bar' };

# header()
is $adapter->header, \%adaptee;

subtest 'nph()' => sub {
    %adaptee = ();
    ok !$adapter->nph;

    $adapter->nph( 1 );
    ok $adapter->nph;
    is $adaptee{-nph}, 1;

    %adaptee = ( -date => 'Sat, 07 Jul 2012 05:05:09 GMT' );
    $adapter->nph( 1 );
    is_deeply \%adaptee, { -nph => 1 };
};

subtest 'field_names()' => sub {
    %adaptee = ( -type => undef );
    my @got = $adapter->field_names;
    my @expected = ( 'Content-Type' );
    is_deeply \@got, \@expected;

    %adaptee = (
        -nph        => 'foo',
        -charset    => 'foo',
        -status     => 'foo',
        -target     => 'foo',
        -p3p        => 'foo',
        -cookie     => 'foo',
        -expires    => 'foo',
        -attachment => 'foo',
        -foo_bar    => 'foo',
        -foo        => q{},
        -bar        => q{},
        -baz        => q{},
        -qux        => q{},
    );

    @got = $adapter->field_names;

    @expected = qw(
        Status
        Window-Target
        P3P
        Set-Cookie
        Expires
        Date
        Content-Disposition
        Foo-bar
        Content-Type
    );

    is_deeply \@got, \@expected;
};

subtest 'DESTROY()' => sub {
    $adapter->DESTROY;
    ok !$adapter->header;
};

use strict;
use Blosxom::Header::Adapter;
use Test::Exception;
use Test::More tests => 10;

my %adaptee;
my $adapter = tie my %adapter => 'Blosxom::Header::Adapter' => \%adaptee;
isa_ok $adapter, 'Blosxom::Header::Adapter';
can_ok $adapter, qw(
    FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
    attachment nph normalize denormalize
);

subtest 'SCALAR()' => sub {
    %adaptee = ();
    ok %adapter;

    %adaptee = ( -type => q{} );
    ok !%adapter;
};

subtest 'CLEAR()' => sub {
    %adaptee = ();
    %adapter = ();
    is_deeply \%adaptee, { -type => q{} };
};

subtest 'EXISTS()' => sub {
    %adaptee = ( -foo => 'bar', -bar => q{} );
    ok exists $adapter{Foo};
    ok !exists $adapter{Bar};
    ok !exists $adapter{Baz};
};

subtest 'DELETE()' => sub {
    %adaptee = ( -foo => 'bar', -bar => 'baz' );
    is delete $adapter{Foo}, 'bar';
    is_deeply \%adaptee, { -bar => 'baz' };
};

subtest 'FETCH()' => sub {
    %adaptee = ( -foo => 'bar' );
    is $adapter{Foo}, 'bar';
    is $adapter{Bar}, undef;
};

subtest 'STORE()' => sub {
    %adaptee = ();
    $adapter{Foo} = 'bar';
    is_deeply \%adaptee, { -foo => 'bar' };
};

subtest 'attachment()' => sub {
    %adaptee = ();
    is $adapter->attachment, undef;
    $adapter->attachment( 'genome.jpg' );
    is $adapter->attachment, 'genome.jpg';
    is $adaptee{-attachment}, 'genome.jpg';
};

subtest 'nph()' => sub {
    %adaptee = ();
    ok !$adapter->nph;
    $adapter->nph( 1 );
    ok $adapter->nph;
    is $adaptee{-nph}, 1;
};

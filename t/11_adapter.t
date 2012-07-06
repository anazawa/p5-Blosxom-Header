use strict;
use Blosxom::Header::Adapter;
use Test::More tests => 19;

my %adaptee;
my $adapter = tie my %adapter, 'Blosxom::Header::Adapter', \%adaptee;
isa_ok $adapter, 'Blosxom::Header::Adapter';
can_ok $adapter, qw(
    FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
    attachment nph normalize denormalize
);

%adaptee = ();
ok %adapter;

%adaptee = ( -type => q{} );
ok !%adapter;

%adaptee = ();
%adapter = ();
is_deeply \%adaptee, { -type => q{} };

%adaptee = ( -foo => 'bar', -bar => q{} );
ok exists $adapter{Foo};
ok !exists $adapter{Bar};
ok !exists $adapter{Baz};

%adaptee = ( -foo => 'bar', -bar => 'baz' );
is delete $adapter{Foo}, 'bar';
is_deeply \%adaptee, { -bar => 'baz' };

%adaptee = ( -foo => 'bar' );
is $adapter{Foo}, 'bar';
is $adapter{Bar}, undef;

%adaptee = ();
$adapter{Foo} = 'bar';
is_deeply \%adaptee, { -foo => 'bar' };

%adaptee = ();
is $adapter->attachment, undef;
$adapter->attachment( 'genome.jpg' );
is $adapter->attachment, 'genome.jpg';
is $adaptee{-attachment}, 'genome.jpg';

%adaptee = ();
ok !$adapter->nph;
$adapter->nph( 1 );
ok $adapter->nph;
is $adaptee{-nph}, 1;

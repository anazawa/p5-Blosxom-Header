use strict;
use Blosxom::Header::Adapter;
use Test::More tests => 12;

my %adaptee;
tie my %adapter => 'Blosxom::Header::Adapter' => \%adaptee;

%adaptee = ();
is_deeply [ each %adapter ], [ 'Content-Type', 'text/html; charset=ISO-8859-1' ];
is_deeply [ each %adapter ], [];

%adaptee = ( -type => q{} );
is_deeply [ each %adapter ], [];

%adaptee = ( -charset => 'foo', -nph => 1 );
is_deeply [ each %adapter ], [ 'Content-Type', 'text/html; charset=foo' ];
is_deeply [ each %adapter ], [];

%adaptee = ( -type => q{}, -charset => 'foo', -nph => 1 );
is_deeply [ each %adapter ], [];

%adaptee = ( -foo => 'bar' );
is_deeply [ each %adapter ], [ 'Content-Type', 'text/html; charset=ISO-8859-1' ];
is_deeply [ each %adapter ], [ 'Foo', 'bar' ];
is_deeply [ each %adapter ], [];

%adaptee = (
    -foo => 'bar',
    -bar => 'baz',
    -baz => 'qux',
);

while ( my ( $field, $value ) = each %adapter ) {
    delete $adapter{ $field };
}

is_deeply \%adaptee, { -type => q{} };

%adaptee = ( -foo => 'Bar' );

for ( values %adapter ) {
    tr/A-Z/a-z/;
}

my %expected = (
    -foo  => 'bar',
    -type => 'text/html; charset=iso-8859-1',
);

is_deeply \%adaptee, \%expected;

%adaptee = (
    -type       => 'foo',
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

%expected = (
    'Content-Disposition' => 'attachment; filename="foo"',
    'Content-Type'        => 'foo; charset=foo',
    'Expires'             => 'foo',
    'Foo-bar'             => 'foo',
    'P3P'                 => 'foo',
    'Set-Cookie'          => 'foo',
    'Status'              => 'foo',
    'Window-Target'       => 'foo',
);

is_deeply \%adapter, \%expected;

use strict;
use Blosxom::Header::Adapter;
use Test::Exception;
use Test::More tests => 13;

my %adaptee;
my $adapter = tie my %adapter => 'Blosxom::Header::Adapter' => \%adaptee;
isa_ok $adapter, 'Blosxom::Header::Adapter';
can_ok $adapter, qw(
    FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
    attachment nph
);

subtest 'SCALAR()' => sub {
    %adaptee = ( -type => q{} );
    ok !%adapter;

    %adaptee = ( -type => q{}, -charset => 'utf-8' );
    ok !%adapter;

    %adaptee = ( -type => q{}, -foo => q{} );
    ok !%adapter;

    %adaptee = ( -type => q{}, -foo => 'bar' );
    ok %adapter;

    %adaptee = ( -foo => 'bar' );
    ok %adapter;
};

subtest 'CLEAR()' => sub {
    %adaptee = ( -foo => 'bar' );
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

subtest 'each()' => sub {
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

    my %expected = (
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
};

#subtest 'is_initialized()' => sub {
#    undef $Header;
#    ok !$adapter->is_initialized, 'should return false';

#    $Header = {};
#    ok $adapter->is_initialized, 'should return true';
#};

#subtest 'header()' => sub {
#    undef $Header;
#    my $expected = qr/\adaptee hasn't been initialized yet/; 
#    throws_ok { $adapter->header } $expected;

#    $Header = {};
#    is $adapter->header, $Header;
#};

subtest 'Content-Type' => sub {
    %adaptee = ( -type => q{} );
    is $adapter{Content_Type}, undef;
    ok !exists $adapter{Content_Type};
    ok !%adapter;

    %adaptee = ();
    is $adapter{Content_Type}, 'text/html; charset=ISO-8859-1';
    ok exists $adapter{Content_Type};
    ok %adapter;

    %adaptee = ( -type => 'text/plain' );
    is $adapter{Content_Type}, 'text/plain; charset=ISO-8859-1';

    %adaptee = ( -charset => 'utf-8' );
    is $adapter{Content_Type}, 'text/html; charset=utf-8';

    %adaptee = ( -type => 'text/plain', -charset => 'utf-8' );
    is $adapter{Content_Type}, 'text/plain; charset=utf-8';

    %adaptee = ( -type => q{} );
    is $adapter{Content_Type}, undef;

    %adaptee = ( -type => q{}, -charset => 'utf-8' );
    is $adapter{Content_Type}, undef;

    %adaptee = ( -type => 'text/plain; charset=EUC-JP' );
    is $adapter{Content_Type}, 'text/plain; charset=EUC-JP';

    %adaptee = (
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    );
    is $adapter{Content_Type}, 'text/plain; charset=euc-jp';

    %adaptee = ( -charset => q{} );
    is $adapter{Content_Type}, 'text/html';

    %adaptee = ();
    $adapter{Content_Type} = 'text/plain; charset=utf-8';
    is_deeply \%adaptee, { -type => 'text/plain; charset=utf-8' };

    %adaptee = ();
    $adapter{Content_Type} = 'text/plain';
    is_deeply \%adaptee, { -type => 'text/plain', -charset => q{} };

    %adaptee = ( -charset => 'euc-jp' );
    $adapter{Content_Type} = 'text/plain; charset=utf-8';
    is_deeply \%adaptee, { -type => 'text/plain; charset=utf-8' };

    %adaptee = ( -type => 'foo' );
    ok exists $adapter{Content_Type};

    %adaptee = ( -type => undef );
    ok exists $adapter{Content_Type};

    #%{ adaptee } = ();
    #undef $adapter{Content_Type};
    #is_deeply adaptee, { -type => q{} };

    %adaptee = ();
    is delete $adapter{Content_Type}, 'text/html; charset=ISO-8859-1';
    is_deeply \%adaptee, { -type => q{} };

    %adaptee = ( -type => q{} );
    is delete $adapter{Content_Type}, undef;
    is_deeply \%adaptee, { -type => q{} };

    %adaptee = ( -type => 'text/plain', -charset => 'utf-8' );
    is delete $adapter{Content_Type}, 'text/plain; charset=utf-8';
    is_deeply \%adaptee, { -type => q{} };
};

subtest 'Content-Disposition' => sub {
    %adaptee = ( -attachment => 'genome.jpg' );
    is $adapter{Content_Disposition}, 'attachment; filename="genome.jpg"';
    ok exists $adapter{Content_Disposition};

    %adaptee = ( -attachment => q{} );
    ok !exists $adapter{Content_Disposition};

    %adaptee = ( -attachment => undef );
    ok !exists $adapter{Content_Disposition};

    %adaptee = ();
    ok !exists $adapter{Content_Disposition};

    %adaptee = ( -content_disposition => 'inline' );
    is $adapter{Content_Disposition}, 'inline';

    %adaptee = ( -attachment => 'foo' );
    $adapter{Content_Disposition} = 'inline';
    is_deeply \%adaptee, { -content_disposition => 'inline' };

    %adaptee = ( -attachment => 'foo' );
    is delete $adapter{Content_Disposition}, 'attachment; filename="foo"';
    is_deeply \%adaptee, {};

    %adaptee = ( -content_disposition => 'inline' );
    is delete $adapter{Content_Disposition}, 'inline';
    is_deeply \%adaptee, {};
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

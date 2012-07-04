use strict;
use Blosxom::Header::Adapter;
use Test::Exception;
use Test::More tests => 13;

{
    package blosxom;
    our $header = {};
}

my $adapter = tie my %adapter => 'Blosxom::Header::Adapter';
isa_ok $adapter, 'Blosxom::Header::Adapter';
can_ok $adapter, qw(
    FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
    attachment nph
);

subtest 'SCALAR()' => sub {
    %{ $blosxom::header } = ( -type => q{} );
    ok !%adapter;

    %{ $blosxom::header } = ( -type => q{}, -charset => 'utf-8' );
    ok !%adapter;

    %{ $blosxom::header } = ( -type => q{}, -foo => q{} );
    ok !%adapter;

    %{ $blosxom::header } = ( -type => q{}, -foo => 'bar' );
    ok %adapter;

    %{ $blosxom::header } = ( -foo => 'bar' );
    ok %adapter;
};

subtest 'CLEAR()' => sub {
    %{ $blosxom::header } = ( -foo => 'bar' );
    %adapter = ();
    is_deeply $blosxom::header, { -type => q{} };
};

subtest 'EXISTS()' => sub {
    %{ $blosxom::header } = ( -foo => 'bar', -bar => q{} );
    ok exists $adapter{Foo};
    ok !exists $adapter{Bar};
    ok !exists $adapter{Baz};
};

subtest 'DELETE()' => sub {
    %{ $blosxom::header } = ( -foo => 'bar', -bar => 'baz' );
    is delete $adapter{Foo}, 'bar';
    is_deeply $blosxom::header, { -bar => 'baz' };
};

subtest 'FETCH()' => sub {
    %{ $blosxom::header } = ( -foo => 'bar' );
    is $adapter{Foo}, 'bar';
    is $adapter{Bar}, undef;
};

subtest 'STORE()' => sub {
    %{ $blosxom::header } = ();
    $adapter{Foo} = 'bar';
    is_deeply $blosxom::header, { -foo => 'bar' };
};

subtest 'each()' => sub {
    %{ $blosxom::header } = ();
    is_deeply [ each %adapter ], [ 'Content-Type', 'text/html; charset=ISO-8859-1' ];
    is_deeply [ each %adapter ], [];

    %{ $blosxom::header } = ( -type => q{} );
    is_deeply [ each %adapter ], [];

    %{ $blosxom::header } = ( -charset => 'foo', -nph => 1 );
    is_deeply [ each %adapter ], [ 'Content-Type', 'text/html; charset=foo' ];
    is_deeply [ each %adapter ], [];

    %{ $blosxom::header } = ( -type => q{}, -charset => 'foo', -nph => 1 );
    is_deeply [ each %adapter ], [];

    %{ $blosxom::header } = ( -foo => 'bar' );
    is_deeply [ each %adapter ], [ 'Content-Type', 'text/html; charset=ISO-8859-1' ];
    is_deeply [ each %adapter ], [ 'Foo', 'bar' ];
    is_deeply [ each %adapter ], [];

    %{ $blosxom::header } = (
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
        'Content-Type'        => 'text/html; charset=foo',
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
#    my $expected = qr/\$blosxom::header hasn't been initialized yet/; 
#    throws_ok { $adapter->header } $expected;

#    $Header = {};
#    is $adapter->header, $Header;
#};

subtest 'Content-Type' => sub {
    %{ $blosxom::header } = ( -type => q{} );
    is $adapter{Content_Type}, undef;
    ok !exists $adapter{Content_Type};
    ok !%adapter;

    %{ $blosxom::header } = ();
    is $adapter{Content_Type}, 'text/html; charset=ISO-8859-1';
    ok exists $adapter{Content_Type};
    ok %adapter;

    %{ $blosxom::header } = ( -type => 'text/plain' );
    is $adapter{Content_Type}, 'text/plain; charset=ISO-8859-1';

    %{ $blosxom::header } = ( -charset => 'utf-8' );
    is $adapter{Content_Type}, 'text/html; charset=utf-8';

    %{ $blosxom::header } = ( -type => 'text/plain', -charset => 'utf-8' );
    is $adapter{Content_Type}, 'text/plain; charset=utf-8';

    %{ $blosxom::header } = ( -type => q{} );
    is $adapter{Content_Type}, undef;

    %{ $blosxom::header } = ( -type => q{}, -charset => 'utf-8' );
    is $adapter{Content_Type}, undef;

    %{ $blosxom::header } = ( -type => 'text/plain; charset=EUC-JP' );
    is $adapter{Content_Type}, 'text/plain; charset=EUC-JP';

    %{ $blosxom::header } = (
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    );
    is $adapter{Content_Type}, 'text/plain; charset=euc-jp';

    %{ $blosxom::header } = ( -charset => q{} );
    is $adapter{Content_Type}, 'text/html';

    %{ $blosxom::header } = ();
    $adapter{Content_Type} = 'text/plain; charset=utf-8';
    is_deeply $blosxom::header, { -type => 'text/plain; charset=utf-8' };

    %{ $blosxom::header } = ();
    $adapter{Content_Type} = 'text/plain';
    is_deeply $blosxom::header, { -type => 'text/plain', -charset => q{} };

    %{ $blosxom::header } = ( -charset => 'euc-jp' );
    $adapter{Content_Type} = 'text/plain; charset=utf-8';
    is_deeply $blosxom::header, { -type => 'text/plain; charset=utf-8' };

    %{ $blosxom::header } = ( -type => 'foo' );
    ok exists $adapter{Content_Type};

    %{ $blosxom::header } = ( -type => undef );
    ok exists $adapter{Content_Type};

    #%{ $blosxom::header } = ();
    #undef $adapter{Content_Type};
    #is_deeply $blosxom::header, { -type => q{} };

    %{ $blosxom::header } = ();
    is delete $adapter{Content_Type}, 'text/html; charset=ISO-8859-1';
    is_deeply $blosxom::header, { -type => q{} };

    %{ $blosxom::header } = ( -type => q{} );
    is delete $adapter{Content_Type}, undef;
    is_deeply $blosxom::header, { -type => q{} };

    %{ $blosxom::header } = ( -type => 'text/plain', -charset => 'utf-8' );
    is delete $adapter{Content_Type}, 'text/plain; charset=utf-8';
    is_deeply $blosxom::header, { -type => q{} };
};

subtest 'Content-Disposition' => sub {
    %{ $blosxom::header } = ( -attachment => 'genome.jpg' );
    is $adapter{Content_Disposition}, 'attachment; filename="genome.jpg"';
    ok exists $adapter{Content_Disposition};

    %{ $blosxom::header } = ( -attachment => q{} );
    ok !exists $adapter{Content_Disposition};

    %{ $blosxom::header } = ( -attachment => undef );
    ok !exists $adapter{Content_Disposition};

    %{ $blosxom::header } = ();
    ok !exists $adapter{Content_Disposition};

    %{ $blosxom::header } = ( -content_disposition => 'inline' );
    is $adapter{Content_Disposition}, 'inline';

    %{ $blosxom::header } = ( -attachment => 'foo' );
    $adapter{Content_Disposition} = 'inline';
    is_deeply $blosxom::header, { -content_disposition => 'inline' };

    %{ $blosxom::header } = ( -attachment => 'foo' );
    is delete $adapter{Content_Disposition}, 'attachment; filename="foo"';
    is_deeply $blosxom::header, {};

    %{ $blosxom::header } = ( -content_disposition => 'inline' );
    is delete $adapter{Content_Disposition}, 'inline';
    is_deeply $blosxom::header, {};
};

subtest 'attachment()' => sub {
    %{ $blosxom::header } = ();
    is $adapter->attachment, undef;
    $adapter->attachment( 'genome.jpg' );
    is $adapter->attachment, 'genome.jpg';
    is $adapter->header->{-attachment}, 'genome.jpg';
};

subtest 'nph()' => sub {
    %{ $blosxom::header } = ();
    ok !$adapter->nph;
    $adapter->nph( 1 );
    ok $adapter->nph;
    is $adapter->header->{-nph}, 1;
};

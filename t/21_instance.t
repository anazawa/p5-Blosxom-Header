use strict;
use Blosxom::Header;
use Test::More tests => 25;
use Test::Warn;
use Test::Exception;

{
    package blosxom;
    our $header;
}

{
    my $expected = qr{^\$blosxom::header hasn't been initialized yet};
    throws_ok { Blosxom::Header->instance } $expected;
}

# Initialize
my %header;
$blosxom::header = \%header;

my $header = Blosxom::Header->instance;
isa_ok $header, 'Blosxom::Header';
can_ok $header, qw(
    clear delete exists field_names get set
    as_hashref is_empty flatten boolify
    content_type type charset
    p3p_tags push_p3p_tags 
    last_modified date expires
    attachment charset nph status target
    set_cookie get_cookie
);

# obsolete methods
can_ok $header, qw( cookie push_cookie p3p push_p3p );

subtest 'exists()' => sub {
    %header = ( -foo => 'bar' );
    ok $header->exists( 'Foo' ), 'should return true';
    ok !$header->exists( 'Bar' ), 'should return false';
};

subtest 'get()' => sub {
    %header = ( -foo => 'bar', -bar => 'baz' );
    my @got = $header->get( 'Foo', 'Bar' );
    my @expected = qw( bar baz );
    is_deeply \@got, \@expected;
};

subtest 'clear()' => sub {
    %header = ( -foo => 'bar' );
    $header->clear;
    is_deeply \%header, { -type => q{} }, 'should be empty';
};

subtest 'set()' => sub {
    %header = ();

    warning_is { $header->set( 'Foo' ) }
        'Odd number of elements in hash assignment';

    $header->set(
        Foo => 'bar',
        Bar => 'baz',
        Baz => 'qux',
    );

    my %expected = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );

    is_deeply \%header, \%expected, 'set() multiple elements';
};

subtest 'delete()' => sub {
    %header = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );

    my @deleted = $header->delete( qw/foo bar/ );
    is_deeply \@deleted, [ 'bar', 'baz' ], 'delete() multiple elements';
    is_deeply \%header, { -baz => 'qux' };
};

subtest 'expires()' => sub {
    %header = ();
    is $header->expires, undef;

    my $now = 1341637509;
    $header->expires( $now );
    is $header->expires, $now, 'get expires()';
    is $header{-expires}, $now;

    $now++;
    $header->expires( 'Sat, 07 Jul 2012 05:05:10 GMT' );
    is $header->expires, $now, 'get expires()';
    is $header{-expires}, 'Sat, 07 Jul 2012 05:05:10 GMT';
};

subtest 'date()' => sub {
    %header = ();
    is $header->date, undef;

    my $now = 1341637509;
    $header->date( $now );
    is $header->date, $now;
    is $header{-date}, 'Sat, 07 Jul 2012 05:05:09 GMT';
};

subtest 'last_modified()' => sub {
    %header = ();
    is $header->last_modified, undef;

    my $now = 1341637509;
    $header->last_modified( $now );
    is $header->last_modified, $now;
    is $header{-last_modified}, 'Sat, 07 Jul 2012 05:05:09 GMT';
};

# OBSOLETE
subtest 'push_cookie()' => sub {
    %header = ();

    my $expected = 'Useless use of _push() with no values';
    warning_is { $header->push_cookie } $expected;

    is $header->push_cookie( 'foo' ), 1, '_push()';
    is $header{-cookie}, 'foo';

    is $header->push_cookie( 'bar' ), 2, '_push()';
    is_deeply $header{-cookie}, [ 'foo', 'bar' ];

    is $header->push_cookie( 'baz' ), 3, '_push()';
    is_deeply $header{-cookie}, [ 'foo', 'bar', 'baz' ];

    %header = ();
    $header->push_cookie({ -name => 'ID', -value => 123456 });
    my $got = $header->cookie;
    isa_ok $got, 'CGI::Cookie';
};

subtest 'status()' => sub {
    %header = ();
    is $header->status, undef;
    $header->status( 304 );
    is $header{-status}, '304 Not Modified';
    is $header->status, '304';
    my $expected = 'Unknown status code "999" passed to status()';
    warning_is { $header->status( 999 ) } $expected;
};

subtest 'charset()' => sub {
    %header = ();
    is $header->charset, 'ISO-8859-1';

    %header = ( -charset => q{} );
    is $header->charset, undef;

    %header = ( -type => q{} );
    is $header->charset, undef;

    %header = ( -type => 'text/html; charset=euc-jp' );
    is $header->charset, 'EUC-JP';

    %header = ( -type => 'text/html; charset=iso-8859-1; Foo=1' );
    is $header->charset, 'ISO-8859-1';

    SKIP: {
        skip 'not supported yet', 1;
        %header = ( -type => 'text/html; charset="iso-8859-1"; Foo=1' );
        is $header->charset, 'ISO-8859-1';
    }
};

subtest 'content_type()' => sub {
    %header = ();
    is $header->content_type, 'text/html';
    my @got = $header->content_type;
    my @expected = ( 'text/html', 'charset=ISO-8859-1' );
    is_deeply \@got, \@expected;

    %header = ( -type => 'text/plain; charset=EUC-JP' );
    is $header->content_type, 'text/plain';
    @got = $header->content_type;
    @expected = ( 'text/plain', 'charset=EUC-JP' );
    is_deeply \@got, \@expected;

    %header = ( -type => 'text/plain; charset=EUC-JP; Foo=1' );
    is $header->content_type, 'text/plain';
    @got = $header->content_type;
    @expected = ( 'text/plain', 'charset=EUC-JP; Foo=1' );
    is_deeply \@got, \@expected;

    %header = ( -charset => 'utf-8' );
    $header->content_type( 'text/plain; charset=EUC-JP' );
    is_deeply $blosxom::header, { -type => 'text/plain; charset=EUC-JP' };

    %header = ( -type => 'text/plain', -charset => 'utf-8' );
    @got = $header->content_type;
    @expected = ( 'text/plain', 'charset=utf-8' );
    is_deeply \@got, \@expected;

    %header = ( -type => 'text/plain; Foo=1', -charset => 'utf-8' );
    @got = $header->content_type;
    @expected = ( 'text/plain', 'Foo=1; charset=utf-8' );
    is_deeply \@got, \@expected;

    %header = (
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    );
    @got = $header->content_type;
    @expected = ( 'text/plain', 'charset=euc-jp' );
    is_deeply \@got, \@expected;

    %header = ( -type => q{} );
    is $header->content_type, q{};
};

subtest 'field_names()' => sub {
    %header = (
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

    my @got = sort $header->field_names;

    my @expected = qw(
        Content-Disposition
        Content-Type
        Date
        Expires
        Foo-bar
        P3P
        Set-Cookie
        Status
        Window-Target
    );

    is_deeply \@got, \@expected;
};

# OBSOLETE
subtest 'cookie()' => sub {
    %header = ();
    $header->cookie( 'foo' );
    is_deeply \%header, { -cookie => 'foo' };

    %header = ();
    $header->cookie( 'foo', 'bar' );
    is_deeply \%header, { -cookie => [qw/foo bar/] };

    %header = ( -cookie => [qw/foo bar/] );
    is $header->cookie, 'foo';
    my @got = $header->cookie;
    my @expected = qw( foo bar );
    is_deeply \@got, \@expected;

    %header = ();
    $header->cookie({ -name => 'ID', -value => 123456 });
    my $got = $header->cookie;
    isa_ok $got, 'CGI::Cookie';
};

subtest 'nph()' => sub {
    %header = ();
    ok !$header->nph;
    $header->nph( 1 );
    ok $header->nph;
    is_deeply \%header, { -nph => 1 };
};

subtest 'attachment()' => sub {
    %header = ();
    is $header->attachment, undef;
    $header->attachment( 'genome.jpg' );
    is $header->attachment, 'genome.jpg';
    is_deeply \%header, { -attachment => 'genome.jpg' };
};

subtest 'target()' => sub {
    %header = ();
    is $header->target, undef;
    $header->target( 'ResultsWindow' );
    is $header->target, 'ResultsWindow';
    is_deeply \%header, { -target => 'ResultsWindow' };
};

subtest 'each()' => sub {
    %header = ( -foo => 'bar' );

    my @got;
    $header->each( sub { push @got, @_ } );

    my @expected = (
        'Foo'          => 'bar',
        'Content-Type' => 'text/html; charset=ISO-8859-1',
    );

    is_deeply \@got, \@expected;

    # DEPRECATED
    %header = ( -foo => 'bar' );
    while ( my $field = $header->each ) {
        $header->delete( $field );
    }
    is_deeply \%header, { -type => q{} };
};

subtest 'is_empty()' => sub {
    %header = ();
    ok !$header->is_empty;

    %header = ( -type => q{} );
    ok $header->is_empty;
};

subtest 'flatten()' => sub {
    %header = ();
    my @got = $header->flatten;
    my @expected = ( 'Content-Type', 'text/html; charset=ISO-8859-1' );
    is_deeply \@got, \@expected;

    %header = ( -p3p => [ 'foo', 'bar' ] );
    @got = $header->flatten;
    @expected = (
        'P3P',          'policyref="/w3c/p3p.xml" CP="foo bar"',
        'Content-Type', 'text/html; charset=ISO-8859-1',
    );
    is_deeply \@got, \@expected;
};

subtest 'as_hashref()' => sub {
    my $got = $header->as_hashref;
    ok ref $got eq 'HASH';

    ok my $adapter = tied( %{ $got } );
    ok $adapter->isa( 'Blosxom::Header::Adapter' );
    ok tied( %{ $header } ) eq $adapter;

    %header = ();
    $header->{Foo} = 'bar';
    is_deeply \%header, { -foo => 'bar' };
};

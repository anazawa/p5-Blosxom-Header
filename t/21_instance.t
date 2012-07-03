use strict;
use Blosxom::Header;
use Test::More tests => 19;
use Test::Warn;

{
    package blosxom;
    our $header;
}

my $header = Blosxom::Header->instance;
isa_ok $header, 'Blosxom::Header';
can_ok $header, qw(
    is_initialized clear delete exists field_names get set
    push_cookie push_p3p
    attachment charset cookie expires nph p3p status target type
);

our $Header;
*Header = \$blosxom::header;

subtest 'is_initialized()' => sub {
    undef $blosxom::header;
    ok !$header->is_initialized, 'should return false';

    $blosxom::header = {};
    ok $header->is_initialized, 'should return true';
};

subtest 'exists()' => sub {
    #$Header = { -foo => 'bar' };
    %{ $blosxom::header } = ( -foo => 'bar' );
    #use Data::Dumper;
    #die Dumper( $header->_proxy->header );
    ok $header->exists( 'Foo' ), 'should return true';
    ok !$header->exists( 'Bar' ), 'should return false';
};

subtest 'get()' => sub {
    #$Header = { -foo => 'bar', -bar => 'baz' };
    %{ $blosxom::header } = ( -foo => 'bar', -bar => 'baz' );
    my @got = $header->get( 'Foo', 'Bar' );
    my @expected = qw( bar baz );
    is_deeply \@got, \@expected;
};

subtest 'clear()' => sub {
    #$Header = { -foo => 'bar' };
    %{ $blosxom::header } = ( -foo => 'bar' );
    $header->clear;
    #is_deeply $Header, { -type => q{} }, 'should be empty';
    is_deeply $blosxom::header, { -type => q{} }, 'should be empty';
};

subtest 'set()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();

    warning_is { $header->set( 'Foo' ) }
        'Odd number of elements in hash assignment';

    warning_is { $header->set } 'Useless use of set() with no values';

    $header->set( Foo => 'baz' );
    is $Header->{-foo}, 'baz', 'set(), not case-sesitive';

    $header->set(
        Bar => 'baz',
        Baz => 'qux',
    );

    my %expected = (
        -foo => 'baz',
        -bar => 'baz',
        -baz => 'qux',
    );

    #is_deeply $Header, \%expected, 'set() multiple elements';
    is_deeply $blosxom::header, \%expected, 'set() multiple elements';
};

subtest 'delete()' => sub {
    #$Header = {
    %{ $blosxom::header } = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );

    warning_is { $header->delete } 'Useless use of delete() with no values';

    my @deleted = $header->delete( qw/foo bar/ );
    is_deeply \@deleted, [ 'bar', 'baz' ], 'delete() multiple elements';
#is_deeply $Header, { -baz => 'qux' };
    is_deeply $blosxom::header, { -baz => 'qux' };
};

subtest 'expires()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    is $header->expires, undef;
    $header->expires( 'now' );
    is $header->expires, 'now', 'get expires()';
    #is $Header->{-expires}, 'now';
    is $blosxom::header->{-expires}, 'now';
};

subtest 'push_cookie()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();

    my $expected = 'Useless use of _push() with no values';
    warning_is { $header->push_cookie } $expected;

    is $header->push_cookie( 'foo' ), 1, '_push()';
    #is $Header->{-cookie}, 'foo';
    is $blosxom::header->{-cookie}, 'foo';

    is $header->push_cookie( 'bar' ), 2, '_push()';
    #is_deeply $Header->{-cookie}, [ 'foo', 'bar' ];
    is_deeply $blosxom::header->{-cookie}, [ 'foo', 'bar' ];

    is $header->push_cookie( 'baz' ), 3, '_push()';
    #is_deeply $Header->{-cookie}, [ 'foo', 'bar', 'baz' ];
    is_deeply $blosxom::header->{-cookie}, [ 'foo', 'bar', 'baz' ];
};

subtest 'status()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    is $header->status, undef;
    $header->status( 304 );
    #is $Header->{-status}, '304 Not Modified';
    is $blosxom::header->{-status}, '304 Not Modified';
    is $header->status, '304';
    my $expected = 'Unknown status code "999" passed to status()';
    warning_is { $header->status( 999 ) } $expected;
};

subtest 'charset()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    is $header->charset, 'ISO-8859-1';

    #$Header = { -charset => q{} };
    %{ $blosxom::header } = ( -charset => q{} );
    is $header->charset, undef;

    #$Header = { -charset => 'utf-8' };
    %{ $blosxom::header } = ( -charset => 'utf-8' );
    is $header->charset, 'UTF-8';

    #$Header = { -type => q{}, -charset => 'utf-8' };
    %{ $blosxom::header } = ( -type => q{}, -charset => 'utf-8' );
    is $header->charset, undef;

    #$Header = { -type => 'text/html; charset=euc-jp' };
    %{ $blosxom::header } = ( -type => 'text/html; charset=euc-jp' );
    is $header->charset, 'EUC-JP';

    #$Header = { -type => 'text/html; charset=euc-jp', -charset => q{}  };
    %{ $blosxom::header } = ( -type => 'text/html; charset=euc-jp', -charset => q{} );
    is $header->charset, 'EUC-JP';

    #$Header = { -type => 'text/html; charset=iso-8859-1; Foo=1' };
    %{ $blosxom::header } = ( -type => 'text/html; charset=iso-8859-1; Foo=1' );
    is $header->charset, 'ISO-8859-1';

    %{ $blosxom::header } = (
        -type    => 'text/html; charset=euc-jp',
        -charset => 'utf-8',
    );
    is $header->charset, 'EUC-JP';
};

subtest 'type()' => sub {
    %{ $blosxom::header } = ();
    is $header->type, 'text/html';
    my @got = $header->type;
    my @expected = ( 'text/html', 'charset=ISO-8859-1' );
    is_deeply \@got, \@expected;

    #$Header = { -type => 'text/plain; charset=EUC-JP' };
    %{ $blosxom::header } = ( -type => 'text/plain; charset=EUC-JP' );
    is $header->type, 'text/plain';
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=EUC-JP' );
    is_deeply \@got, \@expected;

    #$Header = { -type => 'text/plain; charset=EUC-JP; Foo=1' };
    %{ $blosxom::header } = ( -type => 'text/plain; charset=EUC-JP; Foo=1' );
    is $header->type, 'text/plain';
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=EUC-JP; Foo=1' );
    is_deeply \@got, \@expected;

    #$Header = { -charset => 'utf-8' };
    %{ $blosxom::header } = ( -charset => 'utf-8' );
    $header->type( 'text/plain; charset=EUC-JP' );
    is_deeply $Header, { -type => 'text/plain; charset=EUC-JP' };

    #$Header = { -type => 'text/plain', -charset => 'utf-8' };
    %{ $blosxom::header } = ( -type => 'text/plain', -charset => 'utf-8' );
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=utf-8' );
    is_deeply \@got, \@expected;

    #$Header = { -type => 'text/plain; Foo=1', -charset => 'utf-8' };
    %{ $blosxom::header } = ( -type => 'text/plain; Foo=1', -charset => 'utf-8' );
    @got = $header->type;
    @expected = ( 'text/plain', 'Foo=1; charset=utf-8' );
    is_deeply \@got, \@expected;

    %{ $blosxom::header } = (
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    );
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=euc-jp' );
    is_deeply \@got, \@expected;

    %{ $blosxom::header } = ( -type => q{} );
    is $header->type, q{};
};

subtest 'field_names()' => sub {
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

    my @got = sort $header->field_names;

    my @expected = qw(
        Content-Disposition
        Content-Type
        Expires
        Foo-bar
        P3P
        Set-Cookie
        Status
        Window-Target
    );

    #use Data::Dumper;
    #die Dumper( $header->_proxy );

    is_deeply \@got, \@expected;
};

subtest 'p3p()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    $header->p3p( 'CAO' );
    is_deeply $Header, { -p3p => 'CAO' };

    #$Header = {};
    %{ $blosxom::header } = ();
    $header->p3p( 'CAO DSP LAW CURa' );
    is_deeply $Header, { -p3p => [qw/CAO DSP LAW CURa/] };

    #$Header = {};
    %{ $blosxom::header } = ();
    $header->p3p( qw/CAO DSP LAW CURa/ );
    is_deeply $Header, { -p3p => [qw/CAO DSP LAW CURa/] };

    #$Header = { -p3p => 'CAO' };
    %{ $blosxom::header } = ( -p3p => 'CAO' );
    is $header->p3p, 'CAO';

    #$Header = { -p3p => [qw/CAO DSP LAW CURa/] };
    %{ $blosxom::header } = ( -p3p => [qw/CAO DSP LAW CURa/] );
    is $header->p3p, 'CAO';
    my @got = $header->p3p;
    my @expected = qw( CAO DSP LAW CURa );
    is_deeply \@got, \@expected;

    #$Header = { -p3p => [ 'CAO DSP', 'LAW CURa' ] };
    %{ $blosxom::header } = ( -p3p => [ 'CAO DSP', 'LAW CURa' ] );
    is $header->p3p, 'CAO';
    @got = $header->p3p;
    @expected = qw( CAO DSP LAW CURa );
    is_deeply \@got, \@expected;

    #$Header = { -p3p => 'CAO DSP LAW CURa' };
    %{ $blosxom::header } = ( -p3p => 'CAO DSP LAW CURa' );
    is $header->p3p, 'CAO';
    @got = $header->p3p;
    @expected = qw( CAO DSP LAW CURa );
    is_deeply \@got, \@expected;
};

subtest 'cookie()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    $header->cookie( 'foo' );
    is_deeply $Header, { -cookie => 'foo' };

    #$Header = {};
    %{ $blosxom::header } = ();
    $header->cookie( 'foo', 'bar' );
    is_deeply $Header, { -cookie => [qw/foo bar/] };

    #$Header = { -cookie => [qw/foo bar/] };
    %{ $blosxom::header } = ( -cookie => [qw/foo bar/] );
    is $header->cookie, 'foo';
    my @got = $header->cookie;
    my @expected = qw( foo bar );
    is_deeply \@got, \@expected;
};

subtest 'nph()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    ok !$header->nph;
    $header->nph( 1 );
    ok $header->nph;
    #is_deeply $Header, { -nph => 1 };
    is_deeply $blosxom::header, { -nph => 1 };
};

subtest 'attachment()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    is $header->attachment, undef;
    $header->attachment( 'genome.jpg' );
    is $header->attachment, 'genome.jpg';
    #is_deeply $Header, { -attachment => 'genome.jpg' };
    is_deeply $blosxom::header, { -attachment => 'genome.jpg' };
};

subtest 'target()' => sub {
    #$Header = {};
    %{ $blosxom::header } = ();
    is $header->target, undef;
    $header->target( 'ResultsWindow' );
    is $header->target, 'ResultsWindow';
    #is_deeply $Header, { -target => 'ResultsWindow' };
    is_deeply $blosxom::header, { -target => 'ResultsWindow' };
};


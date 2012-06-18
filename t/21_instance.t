use strict;
use Blosxom::Header;
use Test::More tests => 15;
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

subtest 'is_initialized()' => sub {
    ok !$header->is_initialized, 'should return false';
    local $blosxom::header = {};
    ok $header->is_initialized, 'should return true';
};

subtest 'exists()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    ok $header->exists( 'Foo' ), 'should return true';
    ok !$header->exists( 'Bar' ), 'should return false';

    $blosxom::header = { -type => q{} };
    ok !$header->exists( 'Content-Type' );

    $blosxom::header = {};
    ok $header->exists( 'Content-Type' );
};

subtest 'get()' => sub {
    local $blosxom::header = { -foo => [ 'bar', 'baz' ] };
    is $header->get( 'Foo' ), 'bar', 'in scalar context';
    my @got = $header->get( 'Foo' );
    my @expected = qw( bar baz );
    is_deeply \@got, \@expected, 'in list context';

    #$blosxom::header = {};
    #is $header->get( 'Content-Type' ), 'text/html; charset=ISO-8859-1';

    #$blosxom::header = { -type => 'text/plain' };
    #is $header->get( 'Content-Type' ), 'text/plain; charset=ISO-8859-1';

    #$blosxom::header = { -charset => 'utf-8' };
    #is $header->get( 'Content-Type' ), 'text/html; charset=utf-8';

    #$blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    #is $header->get( 'Content-Type' ), 'text/plain; charset=utf-8';
};

subtest 'clear()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    $header->clear;
    is_deeply $blosxom::header, { -type => q{} }, 'should be empty';
};

subtest 'set()' => sub {
    local $blosxom::header = {};

    warning_is { $header->set( 'Foo' ) }
        'Odd number of elements in hash assignment';

    warning_is { $header->set } 'Useless use of set() with no values';

    $header->set( Foo => 'baz' );
    is $blosxom::header->{-foo}, 'baz', 'set(), not case-sesitive';

    $header->set(
        Bar => 'baz',
        Baz => 'qux',
    );

    my %expected = (
        -foo => 'baz',
        -bar => 'baz',
        -baz => 'qux',
    );

    is_deeply $blosxom::header, \%expected, 'set() multiple elements';
};

subtest 'delete()' => sub {
    local $blosxom::header = {
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    };

    warning_is { $header->delete } 'Useless use of delete() with no values';

    my @deleted = $header->delete( qw/foo bar/ );
    is_deeply \@deleted, ['bar', 'baz'], 'delete() multiple elements';
    is_deeply $blosxom::header, { -baz => 'qux' };

    $blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    $header->delete( 'Content-Type' );
    is_deeply $blosxom::header, { -type => q{} };
};

subtest 'expires()' => sub {
    local $blosxom::header = {};
    is $header->expires, undef;
    is $header->expires( 'now' ), 'now', 'set expires()';
    is $header->expires, 'now', 'get expires()';
    is $blosxom::header->{-expires}, 'now';
};

subtest 'push_cookie()' => sub {
    local $blosxom::header = {};

    warning_is { $header->push_cookie }
        'Useless use of _push() with no values';

    is $header->push_cookie( 'foo' ), 1, '_push()';
    is $blosxom::header->{-cookie}, 'foo';

    is $header->push_cookie( 'bar' ), 2, '_push()';
    is_deeply $blosxom::header->{-cookie}, [ 'foo', 'bar' ];

    is $header->push_cookie( 'baz' ), 3, '_push()';
    is_deeply $blosxom::header->{-cookie}, [ 'foo', 'bar', 'baz' ];
};

subtest 'cookie()' => sub {
    local $blosxom::header = {};

    is $header->cookie, undef;
    is $header->cookie( 'foo' ), 'foo', 'set cookie()';
    is $header->cookie,          'foo', 'get cookie()';
    is $blosxom::header->{-cookie}, 'foo';

    my @cookies = qw(foo bar baz);
    $header->cookie( @cookies );
    is_deeply $blosxom::header->{-cookie}, \@cookies, 'cookie() receives LIST';
};

subtest 'status()' => sub {
    local $blosxom::header = {};

    is $header->status, undef;
    is $header->status( 304 ), '304';
    is $blosxom::header->{-status}, '304 Not Modified';
    is $header->status, '304';

    my $expected = 'Unknown status code "999" passed to status()';
    warning_is { $header->status( 999 ) } $expected;
};

subtest 'charset()' => sub {
    local $blosxom::header = {};
    is $header->charset, 'ISO-8859-1';

    $blosxom::header = { -charset => q{} };
    is $header->charset, undef;

    $blosxom::header = { -charset => 'utf-8' };
    is $header->charset, 'UTF-8';

    $blosxom::header = { -type => q{}, -charset => 'utf-8' };
    is $header->charset, undef;

    $blosxom::header = { -type => 'text/html; charset=euc-jp' };
    is $header->charset, 'EUC-JP';

    $blosxom::header = { -type => 'text/html; charset=euc-jp', -charset => q{}  };
    is $header->charset, 'EUC-JP';

    $blosxom::header = { -type => 'text/html; charset=iso-8859-1; Foo=1' };
    is $header->charset, 'ISO-8859-1';

    $blosxom::header = { -type => 'text/html; charset="iso-8859-1"; Foo=1' };
    is $header->charset, 'ISO-8859-1';

    $blosxom::header = {
        -type    => 'text/html; charset=euc-jp',
        -charset => 'utf-8',
    };
    is $header->charset, 'EUC-JP';
};

subtest 'type()' => sub {
    local $blosxom::header = {};
    is $header->type, 'text/html';
    my @got = $header->type;
    my @expected = ( 'text/html', 'charset=ISO-8859-1' );
    is_deeply \@got, \@expected;

    $blosxom::header = { -type => 'text/plain; charset=EUC-JP' };
    is $header->type, 'text/plain';
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=EUC-JP' );
    is_deeply \@got, \@expected;

    $blosxom::header = { -type => 'text/plain; charset=EUC-JP; Foo=1' };
    is $header->type, 'text/plain';
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=EUC-JP; Foo=1' );
    is_deeply \@got, \@expected;

    $blosxom::header = { -charset => 'utf-8' };
    is $header->type( 'text/plain; charset=EUC-JP' ), 'text/plain';
    is_deeply $blosxom::header, { -type => 'text/plain; charset=EUC-JP' };
    #is $blosxom::header->{-type}, 'text/plain; charset=EUC-JP';

    $blosxom::header = {};
    is $header->type( '   TEXT  / HTML   ' ), 'text/html';
    is_deeply $blosxom::header, { -type => '   TEXT  / HTML   ' };
    is $header->type, 'text/html';

    $blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=utf-8' );
    is_deeply \@got, \@expected;

    $blosxom::header = { -type => 'text/plain; Foo=1', -charset => 'utf-8' };
    @got = $header->type;
    @expected = ( 'text/plain', 'Foo=1; charset=utf-8' );
    is_deeply \@got, \@expected;

    $blosxom::header = {
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    };
    @got = $header->type;
    @expected = ( 'text/plain', 'charset=euc-jp' );
    is_deeply \@got, \@expected;
};

subtest 'field_names()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    my @got = sort $header->field_names;
    my @expected = qw( Content-Type Foo );
    is_deeply \@got, \@expected;
};

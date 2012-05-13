use strict;
use Blosxom::Header;
use Test::More;
use Test::Warn;

{
    package blosxom;
    our $header = { -cookie => ['foo', 'bar'] };
}

my $header = Blosxom::Header->instance;

isa_ok $header, 'Blosxom::Header';

can_ok $header, qw(
    exists clear delete get set
    attachment charset expires nph status target type
    cookie push_cookie
    p3p    push_p3p
);

# exists()

ok $header->exists( 'cookie' ), 'exists()';

# get()

warning_is { $header->get( 'cookie' ) }
    'Useless use of get() in void context';

is $header->get( 'cookie' ), 'foo', 'get() in scalar context';

{
    my @got = $header->get( 'cookie' );
    my @expected = qw/foo bar/;
    is_deeply \@got, \@expected, 'get() in list context';
}

# clear()

$header->clear;
is_deeply $blosxom::header, {}, 'clear()';

# set()

eval { $header->set( 'foo' ) };
like $@, qr{^Odd number of elements are passed to set()};

$header->set( -foo => 'bar' );
is $blosxom::header->{-foo}, 'bar', 'set()';

$header->set( Foo => 'baz' );
is $blosxom::header->{-foo}, 'baz', 'set(), not case-sesitive';

$header->clear;

my %fields = (
    -foo => 'bar',
    -bar => 'baz',
    -baz => 'qux',
);

$header->set( %fields );
is_deeply $blosxom::header, \%fields, 'set() multiple elements';

# delete()

my @deleted = $header->delete( qw/foo bar/ );
is_deeply \@deleted, ['bar', 'baz'], 'delete() multiple elements';
is_deeply $blosxom::header, { -baz => 'qux' };

is $header->expires, undef;
is $header->expires( 'now' ), 'now', 'set expires()';
is $header->expires, 'now', 'get expires()';
is $blosxom::header->{-expires}, 'now';

$header->clear;

# Set-Cookie

warning_is { $header->push_cookie } 'Useless use of _push() with no values';

is $header->push_cookie( 'foo' ), 1, '_push()';
is $blosxom::header->{-cookie}, 'foo';

is $header->push_cookie( 'bar' ), 2, '_push()';
is_deeply $blosxom::header->{-cookie}, ['foo', 'bar'];

is $header->push_cookie( 'baz' ), 3, '_push()';
is_deeply $blosxom::header->{-cookie}, ['foo', 'bar', 'baz'];

$header->clear;

is $header->cookie, undef;
is $header->cookie( 'foo' ), 'foo', 'set cookie()';
is $header->cookie, 'foo', 'get cookie()';
is $blosxom::header->{-cookie}, 'foo';

my @cookies = qw(foo bar baz);
is_deeply $header->cookie( @cookies ), \@cookies, 'cookie() receives LIST';
is_deeply $blosxom::header->{-cookie}, \@cookies;

$header->clear;

# P3P

is $header->p3p, undef;
is $header->p3p( 'foo' ), 'foo', 'set p3p()';
is $header->p3p, 'foo', 'get p3p()';
is $blosxom::header->{-p3p}, 'foo';

$header->clear;

my @p3p = qw(foo bar baz);
is_deeply $header->p3p( @p3p ), \@p3p, 'p3p() receives LIST';
is_deeply $blosxom::header->{-p3p}, \@p3p;

$header->clear;

done_testing;

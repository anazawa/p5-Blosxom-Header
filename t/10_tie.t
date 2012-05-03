use strict;
use Blosxom::Header;
use Test::More;

{
    package blosxom;
    our $header;
}

eval { tie my %header, 'Blosxom::Header' };
like $@, qr{^\$blosxom::header hasn't been initialized yet};

# initialize
$blosxom::header = { -foo => 'bar' };

my $header = tie my %header, 'Blosxom::Header';

ok exists $header{-foo}, 'EXISTS() returns true';
ok !exists $header{-bar}, 'EXISTS() returns false';
ok exists $header{Foo}, 'EXISTS(), not case-sensitive';

is $header{-foo}, 'bar', 'FETCH()';
is $header{-bar}, undef, 'FETCH() undef';
is $header{Foo}, 'bar', 'FETCH(), not case-sensitive';

%header = ();
is_deeply $blosxom::header, {}, 'CLEAR()';

$header{-foo} = 'bar';
is_deeply $blosxom::header, { -foo => 'bar' }, 'STORE()';

%header = (
    Last_Modified => 'Thu, 03 Feb 1994 00:00:00 GMT',
    status        => '304 Not Modified',
    type          => 'text/html',
);

{
    my @got = sort keys %header;
    my @expected = qw/Last_Modified status type/;
    is_deeply \@got, \@expected, 'keys';
}

%header = (
    -foo => 'bar',
    -bar => 'baz',
    -baz => 'qux',
);

is delete $header{-foo}, 'bar', 'DELETE()';
is delete $header{-foo}, undef, 'DELETE() nothing';
is delete $header{Bar}, 'baz', 'DELETE(), not case-sensitive';

is_deeply $blosxom::header, { -baz => 'qux' };

done_testing;

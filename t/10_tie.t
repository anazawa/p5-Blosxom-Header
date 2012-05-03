use strict;
use Blosxom::Header;
use Test::More;

{
    package blosxom;
    our $header;
}

eval { Blosxom::Header->TIEHASH };
like $@, qr{^\$blosxom::header hasn't been initialized yet};

$blosxom::header = { -foo => 'bar' };

{
    tie my %header, 'Blosxom::Header';

    ok exists $header{-foo}, 'EXISTS() returns true';
    ok !exists $header{-bar}, 'EXISTS() returns false';
    ok exists $header{Foo}, 'EXISTS(), not case-sensitive';

    is $header{-foo}, 'bar', 'FETCH()';
    is $header{-bar}, undef, 'FETCH() undef';
    is $header{Foo}, 'bar', 'FETCH(), not case-sensitive';

    %header = ();
}

is_deeply $blosxom::header, {}, 'CLEAR()';

$blosxom::header = {
    Last_Modified => 'Thu, 03 Feb 1994 00:00:00 GMT',
    status        => '304 Not Modified',
    type          => 'text/html',
};

{
    tie my %header, 'Blosxom::Header';

    my @got = sort keys %header;
    my @expected = qw/Last_Modified status type/;
    is_deeply \@got, \@expected, 'keys';
}

{
    tie my %header, 'Blosxom::Header';
    %header = ();

    $header{-foo} = 'bar';
    is $header{-foo}, 'bar', 'STORE()';

    $header{Bar} = 'baz';
    is $header{-bar}, 'baz', 'STORE(), not case-sensitive';
}

{
    my %expected = (
        -foo => 'bar',
        Bar => 'baz'
    );

    is_deeply $blosxom::header, \%expected;
}

$blosxom::header = {
    -foo => 'bar',
    -bar => 'baz',
};

{
    tie my %header, 'Blosxom::Header';

    is delete $header{-foo}, 'bar', 'DELETE()';
    is delete $header{-foo}, undef, 'DELETE() nothing';
    is delete $header{Bar}, 'baz', 'DELETE(), not case-sensitive';
}

is_deeply $blosxom::header, {};

done_testing;

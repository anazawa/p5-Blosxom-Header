use strict;
use Blosxom::Header;
use Test::More;

{
    package blosxom;
    our $header;
}

$blosxom::header = { -cookie => ['foo', 'bar'] };

{
    my $header = Blosxom::Header->new;
    is $header->get( 'cookie' ), 'foo', 'get() in scalar context';

    my @got = $header->get( 'cookie' );
    my @expected = qw/foo bar/;
    is_deeply \@got, \@expected, 'get() in list context';
}

$blosxom::header = {
    -foo => 'bar',
    -bar => 'baz',
    -baz => 'qux',
};

{
    my $header = Blosxom::Header->new;
    my @got = $header->delete( qw/foo bar/ );
    my @expected = qw/bar baz/;
    is_deeply \@got, \@expected, 'delete() multiple elements';
}

is_deeply $blosxom::header, { -baz => 'qux' };

$blosxom::header = {};

{
    my $header = Blosxom::Header->new;
    eval { $header->set( 'foo' ) };
    like $@, qr{^Odd number of elements are passed to set()};
    $header->set(
        foo => 'bar',
        bar => 'baz',
    );
}

{
    my %expected = (
        foo => 'bar',
        bar => 'baz',
    );

    is_deeply $blosxom::header, \%expected, 'set() multiple elements';
}

done_testing;

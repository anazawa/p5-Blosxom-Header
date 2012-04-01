use strict;
use Test::More;
use Test::Warn;
use Blosxom::Header;

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar' });
    ok $h->exists( '-foo' );
    ok !$h->exists( '-bar' );
    ok $h->exists( 'Foo' ), 'exists case-sensitive';
}

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar', 'foo' => 'baz' });
    my $bool;
    warning_is { $bool = $h->exists( 'foo' ) }
        '2 elements specify the foo header.';
    is $bool, 2;
}

done_testing;

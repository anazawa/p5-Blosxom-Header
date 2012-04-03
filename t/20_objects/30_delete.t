use strict;
use Test::More;
use Blosxom::Header;

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar', '-bar' => 'baz' });
    $h->delete( '-foo' );
    is_deeply $h->header, { '-bar' => 'baz' };
}

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar', '-bar' => 'baz' });
    $h->delete( 'Foo' );
    is_deeply $h->header, { '-bar' => 'baz' }, 'delete case-sensitive';
}

{
    my $h = Blosxom::Header->new({
        '-foo' => 'bar',
        'foo'  => 'baz',
        '-bar' => 'baz'
    });
    $h->delete( 'Foo' );
    is_deeply $h->header, { '-bar' => 'baz' }, 'delete multiple elements';
}

done_testing;

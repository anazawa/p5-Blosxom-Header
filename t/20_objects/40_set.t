use strict;
use Test::More;
use Blosxom::Header;

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar' });
    $h->set( '-bar' => 'baz' );
    is_deeply $h->header, { '-foo' => 'bar', 'bar' => 'baz' };
}

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar' });
    $h->set( '-bar' => q{} );
    is_deeply $h->header, { '-foo' => 'bar', 'bar' => q{} }, 'set empty string';
}

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar' });
    $h->set( '-foo' => 'baz' );
    is_deeply $h->header, { '-foo' => 'baz' }, 'set overwrite';
}

{
    my $h = Blosxom::Header->new({ '-foo' => 'bar' });
    $h->set( Foo => 'baz' );
    is_deeply $h->header, { '-foo' => 'baz' }, 'set case-sensitive';
}

{
    my $h = Blosxom::Header->new({ foo => 'bar' });
    $h->set( foo => [ 'bar', 'baz' ] );
    is_deeply $h->header, { 'foo' => [ 'bar', 'baz' ] }, 'set arrayref';
}

{
    my $h = Blosxom::Header->new({ foo => 'bar', '-foo' => 'baz' });
    $h->set( foo => 'qux' );
    is_deeply $h->header, { '-foo' => 'qux' };
}

done_testing;

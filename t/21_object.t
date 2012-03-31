use strict;
use Blosxom::Header;
use Test::More;

{
    my $h = Blosxom::Header->new({ foo => 'bar' });
    is $h->get('foo'), 'bar';
    ok $h->exists('foo');

    $h->set( bar => 'baz' );
    is_deeply $h->header, { foo => 'bar', bar => 'baz' };

    $h->delete( 'foo' );
    is_deeply $h->header, { bar => 'baz' };
}

{
    my $h = Blosxom::Header->new({});

    $h->push( 'cookie', 'foo' );
    is_deeply $h->header, { cookie => [ 'foo' ] };
}

{
    my $h = Blosxom::Header->new({ cookie => [ 'foo', 'bar' ] });
    is $h->get( 'cookie' ), 'foo';

    my @values = $h->get( 'cookie' );
    is_deeply \@values, [ 'foo', 'bar' ];
}

done_testing;

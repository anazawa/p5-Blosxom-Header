use strict;
use Test::More;
use Blosxom::Header;

{
    my $h = Blosxom::Header->new({});
    $h->push( 'cookie', 'foo' );
    is_deeply $h->header, { cookie => 'foo' };
}

{
    my $h = Blosxom::Header->new({ cookie => 'foo' });
    $h->push( 'cookie', 'bar' );
    is_deeply $h->header, { cookie => [ 'foo', 'bar' ] };
}

{
    my $h = Blosxom::Header->new({ cookie => [ 'foo' ] });
    $h->push( 'cookie', 'bar' );
    is_deeply $h->header, { cookie => [ 'foo', 'bar' ] };
}

{
    my $h = Blosxom::Header->new({});
    $h->push( 'p3p', 'foo' );
    is_deeply $h->header, { p3p => 'foo' };
}

{
    my $h = Blosxom::Header->new({ p3p => 'foo' });
    $h->push( 'p3p', 'bar' );
    is_deeply $h->header, { p3p => [ 'foo', 'bar' ] };
}

{
    my $h = Blosxom::Header->new({ p3p => [ 'foo' ] });
    $h->push( 'p3p', 'bar' );
    is_deeply $h->header, { p3p => [ 'foo', 'bar' ] };
}

{
    my $h = Blosxom::Header->new({});
    eval { $h->push( 'foo', 'bar' ) };
    like $@, qr{^Can't push the foo header};
}

{
    my $h = Blosxom::Header->new({ cookie => 'foo', '-cookie' => 'bar' });
    eval { $h->push( 'cookie', 'baz' ) };
    like $@, qr{^Multiple elements specify the cookie header};
}

done_testing;

use strict;
use Test::More;
use Blosxom::Header;

{
    my $header = Blosxom::Header->new({});
    $header->push( -foo => 'bar' );
    is_deeply $header->{header}, { -foo => 'bar' }, 'push';
}

{
    my $header = Blosxom::Header->new({});
    $header->push(
        -foo => 'bar',
        -bar => 'baz',
    );
    my $expected = { -foo => 'bar', -bar => 'baz' };
    is_deeply $header->{header}, $expected, 'push multiple elements';
}

{
    my $header = Blosxom::Header->new({});
    $header->push( Foo => 'bar' );
    is_deeply $header->{header}, { -foo => 'bar' }, 'push, not case-sensitive';
}

{
    my $header = Blosxom::Header->new({ -cookie => 'foo' });
    $header->push( 'Set-Cookie' => 'bar' );
    my $expected = { -cookie => [ 'foo', 'bar' ] };
    is_deeply $header->{header}, $expected, 'push';
}

{
    my @cookies = ( 'foo' );
    my $header = Blosxom::Header->new({ -cookie => \@cookies });
    $header->push( 'Set-Cookie' => 'bar' );
    my $expected = { -cookie => [ 'foo', 'bar' ] };
    is_deeply $header->{header}, $expected, 'push';
    is $header->{header}->{-cookie}, \@cookies, 'push';
}

done_testing;

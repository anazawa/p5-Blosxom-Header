use strict;
use Test::More;
use Blosxom::Header;

{
    my %tests = (
        'foo'          => 'foo',
        'Foo'          => 'foo',
        '-foo'         => 'foo',
        '-Foo'         => 'foo',
        'foo-bar'      => 'foo-bar',
        'Foo-bar'      => 'foo-bar',
        'foo-Bar'      => 'foo-bar',
        'Foo-Bar'      => 'foo-bar',
        'foo_bar'      => 'foo-bar',
        'Foo_bar'      => 'foo-bar',
        'foo_Bar'      => 'foo-bar',
        'Foo_Bar'      => 'foo-bar',
        '-foo-bar'     => 'foo-bar',
        '-Foo-bar'     => 'foo-bar',
        '-foo-Bar'     => 'foo-bar',
        '-Foo-Bar'     => 'foo-bar',
        '-foo_bar'     => 'foo-bar',
        '-Foo_bar'     => 'foo-bar',
        '-foo_Bar'     => 'foo-bar',
        '-Foo_Bar'     => 'foo-bar',
        'content-type' => 'type',
        'set-cookie'   => 'cookie',
    );

    while ( my ( $input, $output ) = each %tests ) {
        is Blosxom::Header::_norm( $input ), $output;
    }
}

done_testing;

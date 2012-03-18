use strict;
use Test::More;
use Blosxom::Header;

{
    my @tests = (
        [ 'foo'           => 'foo'     ],
        [ 'Foo'           => 'foo'     ],
        [ '-foo'          => 'foo'     ],
        [ '-Foo'          => 'foo'     ],
        [ 'foo-bar'       => 'foo-bar' ],
        [ 'Foo-bar'       => 'foo-bar' ],
        [ 'foo-Bar'       => 'foo-bar' ],
        [ 'Foo-Bar'       => 'foo-bar' ],
        [ 'foo_bar'       => 'foo-bar' ],
        [ 'Foo_bar'       => 'foo-bar' ],
        [ 'foo_Bar'       => 'foo-bar' ],
        [ 'Foo_Bar'       => 'foo-bar' ],
        [ '-foo-bar'      => 'foo-bar' ],
        [ '-Foo-bar'      => 'foo-bar' ],
        [ '-foo-Bar'      => 'foo-bar' ],
        [ '-Foo-Bar'      => 'foo-bar' ],
        [ '-foo_bar'      => 'foo-bar' ],
        [ '-Foo_bar'      => 'foo-bar' ],
        [ '-foo_Bar'      => 'foo-bar' ],
        [ '-Foo_Bar'      => 'foo-bar' ],
        [ 'content-type'  => 'type'    ],
        [ 'Content-type'  => 'type'    ],
        [ 'content-Type'  => 'type'    ],
        [ 'Content-Type'  => 'type'    ],
        [ 'content_type'  => 'type'    ],
        [ 'Content_type'  => 'type'    ],
        [ 'content_Type'  => 'type'    ],
        [ 'Content_Type'  => 'type'    ],
        [ '-content-type' => 'type'    ],
        [ '-Content-type' => 'type'    ],
        [ '-content-Type' => 'type'    ],
        [ '-Content-Type' => 'type'    ],
        [ '-content_type' => 'type'    ],
        [ '-Content_type' => 'type'    ],
        [ '-content_Type' => 'type'    ],
        [ '-Content_Type' => 'type'    ],
    );

    for my $test ( @tests ) {
        my ( $input, $output ) = @{ $test };
        is Blosxom::Header::_norm( $input ), $output;
    }
}

done_testing;

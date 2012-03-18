use strict;
use Test::More;
use Test::Warn;
use Blosxom::Header qw(get_header);

{
    my $header_ref = { '-foo' => 'bar' };
    is get_header( $header_ref, '-foo' ), 'bar';
}

{
    my $header_ref = { '-foo' => 'bar' };
    is get_header( $header_ref, 'Foo' ), 'bar', 'get case-sensitive';
}

{
    my $header_ref = { '-foo' => [ 'bar', 'baz' ] };
    is get_header( $header_ref, 'foo' ), 'bar', 'get scalar context';

    my @values = get_header( $header_ref, 'foo' );
    is_deeply \@values, [ 'bar', 'baz' ], 'get list context';
}

{
    my $header_ref = { '-foo' => 'bar', 'foo' => 'baz' };
    warning_is { get_header( $header_ref, 'foo' ) }
        'Multiple elements specify the same field: -foo foo';
}

done_testing;

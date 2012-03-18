use strict;
use Test::More;
use Test::Warn;
use Blosxom::Header qw(exists_header);

{
    my $header_ref = { '-foo' => 'bar', '-bar' => 'baz' };
    ok exists_header( $header_ref, '-foo' );
    ok !exists_header( $header_ref, 'baz' );
}

{
    my $header_ref = { '-foo' => 'bar', '-bar' => 'baz' };
    ok exists_header( $header_ref, 'Foo' ), 'exists case-sensitive';
}

{
    my $header_ref = { '-foo' => 'bar', 'foo' => 'baz' };
    my $bool;
    warning_is { $bool = exists_header( $header_ref, 'foo' ) }
        'Multiple elements specify the same field: -foo foo';
    ok $bool;
}

done_testing;

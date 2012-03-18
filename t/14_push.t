use strict;
use Test::More;
use Blosxom::Header qw(push_header);

{
    my $header_ref = {};
    push_header( $header_ref, 'cookie', 'foo' );
    is_deeply $header_ref, { cookie => [ 'foo' ] };
}

{
    my $header_ref = { cookie => [ 'foo' ] };
    push_header( $header_ref, 'cookie', 'bar' );
    is_deeply $header_ref, { cookie => [ 'foo', 'bar' ] };
}

{
    my $header_ref = { cookie => 'foo' };
    push_header( $header_ref, 'cookie', 'bar' );
    is_deeply $header_ref, { cookie => [ 'foo', 'bar' ] };
}

{
    my $header_ref = {};
    push_header( $header_ref, 'p3p', 'foo' );
    is_deeply $header_ref, { p3p => [ 'foo' ] };
}

{
    my $header_ref = { p3p => [ 'foo' ] };
    push_header( $header_ref, 'p3p', 'bar' );
    is_deeply $header_ref, { p3p => [ 'foo', 'bar' ] };
}

{
    my $header_ref = { p3p => 'foo' };
    push_header( $header_ref, 'p3p', 'bar' );
    is_deeply $header_ref, { p3p => [ 'foo', 'bar' ] };
}

{
    my $header_ref = {};
    eval { push_header( $header_ref, 'foo', 'bar' ) };
    like $@, qr{Can't push the foo field.};
}

done_testing;

use strict;
use Test::More;
use Test::Warn;
use Blosxom::Header;

{
    my $header = Blosxom::Header->new({});
    $header->push_cookie( 'foo' );
    is_deeply $header->{header}, { -cookie => 'foo' }, 'push';
}

{
    my $header = Blosxom::Header->new({});
    $header->push_cookie( qw/foo bar/ );
    my $expected = { -cookie => [ 'foo', 'bar' ] };
    is_deeply $header->{header}, $expected, 'push multiple values';
}

#{
#    my $header = Blosxom::Header->new({});
#    $header->push_cookie('=> 'bar' );
#    is_deeply $header->{header}, { -foo => 'bar' }, 'push, not case-sensitive';
#}

{
    my $header = Blosxom::Header->new({ -cookie => 'foo' });
    $header->push_cookie( 'bar' );
    my $expected = { -cookie => [ 'foo', 'bar' ] };
    is_deeply $header->{header}, $expected, 'push';
}

{
    my @cookies = ( 'foo' );
    my $header = Blosxom::Header->new({ -cookie => \@cookies });
    $header->push_cookie( 'bar' );
    my $expected = { -cookie => [ 'foo', 'bar' ] };
    is_deeply $header->{header}, $expected, 'push';
    is $header->{header}->{-cookie}, \@cookies, 'push';
}

{
    my $header = Blosxom::Header->new({});
    warning_is { $header->push_cookie } 'Useless use of push_cookie with no values';
}

done_testing;

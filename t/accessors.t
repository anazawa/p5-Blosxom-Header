use strict;
use Blosxom::header;
use Test::More;

{
    my $header = Blosxom::Header->new({ -attachment => 'foo' });
    can_ok $header, qw( attachment charset cookie expires nph p3p target type );
    is $header->attachment, 'foo';
    $header->attachment( 'bar' );
    is_deeply $header->{header}, { -attachment => 'bar' };
};

done_testing;

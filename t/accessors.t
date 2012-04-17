use strict;
use Blosxom::header;
use Test::More;

{
    my $header = Blosxom::Header->new({ -attachment => 'foo' });
    is $header->attachment, 'foo';
    $header->attachment( 'bar' );
    is_deeply $header->{header}, { -attachment => 'bar' };
};

done_testing;

use strict;
use warnings;
use Test::More tests => 1;
use Blosxom::Headers;

{
    package blosxom;

    our $header = {
        -type          => 'text/html; charset=UTF-8',
        -status        => '304 Not Modified',
        -cache_control => 'must-revalidate',
    };
}

my $header = Blosxom::Headers->new();

my @keys = sort $header->keys();
is_deeply(\@keys, [qw(cache_control status type)]);


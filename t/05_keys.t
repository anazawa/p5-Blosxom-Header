use strict;
use warnings;
use Test::More tests => 1;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type          => 'text/html;',
        -status        => '304 Not Modified',
        -cache_control => 'must-revalidate',
    };
}

my $header = Blosxom::Header->new();

my @keys = sort $header->keys();
is_deeply(\@keys, [qw(cache_control status type)]);


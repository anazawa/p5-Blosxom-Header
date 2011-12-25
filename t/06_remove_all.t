use strict;
use warnings;
use Test::More tests => 2;
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

my @deleted = sort $header->remove_all();
is_deeply($blosxom::header, {}                             );
is_deeply(\@deleted,        [qw(cache_control status type)]);


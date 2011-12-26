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

my @deleted = sort $header->remove_all();
is_deeply($blosxom::header, {});


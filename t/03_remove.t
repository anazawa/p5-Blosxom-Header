use strict;
use warnings;
use Test::More tests => 6;
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

$header->remove('type');
is($header->exists('type'),          q{});
is($header->exists('status'),        1  );
is($header->exists('cache_control'), 1  );

$header->remove('status', 'cache_control');
is($header->exists('type'),          q{});
is($header->exists('status'),        q{});
is($header->exists('cache_control'), q{});


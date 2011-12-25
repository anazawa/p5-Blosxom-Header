use strict;
use warnings;
use Test::More tests => 2;
use Blosxom::Headers;

{
    package blosxom;
    our $header;
}

my $header = Blosxom::Headers->new();
is($header->exists('type'), q{});

$blosxom::header = { -type => "text/html; charset=UTF-8" };
is($header->exists('type'), 1);


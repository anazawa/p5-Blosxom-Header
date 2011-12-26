use strict;
use warnings;
use Test::More tests => 2;
use Blosxom::Header;

{
    package blosxom;
    our $header;
}

my $header = Blosxom::Header->new();
is($header->exists('type'), q{});

$blosxom::header = { -type => 'text/html;' };
is($header->exists('type'), 1);


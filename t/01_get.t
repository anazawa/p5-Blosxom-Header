use strict;
use warnings;
use Test::More tests => 2;
use Blosxom::Headers;

{
    package blosxom;
    our $header;
}

my $header = Blosxom::Headers->new();
is($header->get('type'), undef);

$blosxom::header = { -type => 'text/html;' };
is($header->get('type'),  'text/html;');


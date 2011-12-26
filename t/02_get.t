use strict;
use warnings;
use Test::More tests => 2;
use Blosxom::Header;

{
    package blosxom;
    our $header;
}

my $header = Blosxom::Header->new();
is($header->get('type'), undef);

$blosxom::header = { -type => 'text/html;' };
is($header->get('type'),  'text/html;');


use strict;
use Test::More tests => 4;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type => 'text/html',
    };
}

my $header = Blosxom::Header->new();

is($header->exists('Content-Type'), 1);
is($header->exists('Content-Length'), undef);
is($header->exists(), undef);
is_deeply($blosxom::header, {
    '-type' => 'text/html',
});


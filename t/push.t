use strict;
use Test::More tests => 2;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type => 'text/html',
    };
}

my $header = Blosxom::Header->new();
$header->push('Accept' => 'image/jpeg');

is_deeply($blosxom::header, {
    -type => 'text/html',
    -Accept => 'image/jpeg',
});

$header->push('Accept' => 'text/html');

is_deeply($blosxom::header, {
    -type => 'text/html',
    -Accept => 'image/jpeg, text/html',
});

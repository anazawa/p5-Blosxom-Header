use strict;
use Test::More tests => 2;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type => 'text/html',
    };
}

{
    my $header = Blosxom::Header->new();
    $header->set( 'Content-Length' => '1234' );
}

is_deeply($blosxom::header, {
    '-type'   => 'text/html',
    '-Content-Length' => '1234',
});

# override
{
    my $header = Blosxom::Header->new();
    $header->set('Content-Type' => 'text/plain');
}

is_deeply($blosxom::header, {
    '-type'   => 'text/plain',
    '-Content-Length' => '1234',
});


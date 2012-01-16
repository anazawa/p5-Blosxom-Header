use strict;
use Test::More tests => 2;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type => 'text/html;',
    };
}

{
    my $header = Blosxom::Header->new(
        'Content-Type' => 'text/plain;',
        'Status'       => '304 Not Modified',
    );

    is_deeply($header, {
        'Content-Type' => 'text/plain;',
        'Status'       => '304 Not Modified',
    });
}

is_deeply($blosxom::header, {
    '-Content-Type'   => 'text/plain;',
    '-Status' => '304 Not Modified',
});


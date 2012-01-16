use strict;
use Test::More tests => 3;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type => 'text/html;',
    };
}

{
    my $header = Blosxom::Header->new();
    $header->set( 'Content-Length' => '1234' );
}

{
    my $expected = {
        '-Content-Type'   => 'text/html;',
        '-Content-Length' => '1234',
    };

    is_deeply($blosxom::header, $expected);
}

{
    my $header = Blosxom::Header->new();
    $header->set(
        'Cache-Control' => 'must-revalidate',
        'Last-Modified' => 'Wed, 15 Nov 1995 04:58:08 GMT',
    );
}

{
    my $expected = {
        '-Content-Type'   => 'text/html;',
        '-Content-Length' => '1234',
        '-Cache-Control'  => 'must-revalidate',
        '-Last-Modified'  => 'Wed, 15 Nov 1995 04:58:08 GMT',
    };

    is_deeply($blosxom::header, $expected);
}

# override
{
    my $header = Blosxom::Header->new();
    $header->set('Content-Type' => 'text/plain;');
}

{
    my $expected = {
        '-Content-Type'   => 'text/plain;',
        '-Content-Length' => '1234',
        '-Cache-Control'  => 'must-revalidate',
        '-Last-Modified'  => 'Wed, 15 Nov 1995 04:58:08 GMT',
    };

    is_deeply($blosxom::header, $expected);
}


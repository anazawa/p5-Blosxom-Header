use strict;
use Test::More tests => 2;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        '-type' => 'text/html',
        '-Content-Length' => '1234',
    };
}

{
    my $header = Blosxom::Header->new();
    $header->remove('Content-Length');
}

is_deeply($blosxom::header, {
    '-type'   => 'text/html',
    #'-Content-Length' => '1234',
});

#{
#    my $header = Blosxom::Header->new();
#    $header->set(
#        'Cache-Control' => 'must-revalidate',
#        'Last-Modified' => 'Wed, 15 Nov 1995 04:58:08 GMT',
#    );
#}

#is_deeply($blosxom::header, {
#    '-Content-Type'   => 'text/html',
#    '-Content-Length' => '1234',
    #'-Cache-Control'  => 'must-revalidate',
    #'-Last-Modified'  => 'Wed, 15 Nov 1995 04:58:08 GMT',
#});

# override
{
    my $header = Blosxom::Header->new();
    $header->remove('Content-Length');
}

is_deeply($blosxom::header, {
    '-type'   => 'text/html',
    #'-Content-Length' => '1234',
    #'-Cache-Control'  => 'must-revalidate',
    #'-Last-Modified'  => 'Wed, 15 Nov 1995 04:58:08 GMT',
});


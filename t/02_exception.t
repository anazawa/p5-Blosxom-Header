use strict;
use Test::More tests => 2;
use Test::Exception;
use Blosxom::Header;

{
    package blosxom;
    our $header;
}

throws_ok { Blosxom::Header->new() }
    qr{\$blosxom::header have not been initialized yet};

$blosxom::header = {};

lives_ok { Blosxom::Header->new() };

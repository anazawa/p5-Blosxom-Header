use strict;
use Blosxom::Header;
use Test::More;

{
    package blosxom;
    our $header = { -type => 'text/html' };
}

tie my %header, 'Blosxom::Header', 'ro';

is $header{type}, 'text/html';

eval { $header{type} = 'text/plain' };
like $@, qr{^Modification of a read-only value attempted};

done_testing;


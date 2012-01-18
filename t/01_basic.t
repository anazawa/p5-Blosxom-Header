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

isa_ok($header, 'Blosxom::Header');
can_ok($header, qw/new remove set get exists/);
#is_deeply($header, {hash_ref => $blosxom::header});

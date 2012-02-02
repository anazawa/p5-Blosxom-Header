use strict;
use Test::More;
use Blosxom::Header;

{
    my $headers = { -type => 'text/plain' };
    my $h = Blosxom::Header->new($headers);
    is $h->type(), 'text/plain';
}

{
    my $headers = {};
    my $h = Blosxom::Header->new($headers);
    $h->type('text/plain');
    is_deeply $headers, { -type => 'text/plain' };
}

done_testing;

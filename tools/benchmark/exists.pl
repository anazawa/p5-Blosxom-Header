use strict;
use warnings;
use Benchmark qw/cmpthese/;
use Blosxom::Header::Adapter;

my $header = Blosxom::Header::Adapter->TIEHASH({
    -type    => 'text/plain',
    -charset => 'utf-8',
    -nph     => 1,
    -foo     => 'bar',
});

cmpthese(-1, {
    'Content-Type' => sub {
        my $bool = $header->EXISTS('Content-Type');
    },
    'Content-Disposition' => sub {
        my $bool = $header->EXISTS('Content-Disposition');
    },
    'Date' => sub {
        my $bool = $header->EXISTS('Date');
    },
    'Foo' => sub {
        my $bool = $header->EXISTS('Foo');
    },
});

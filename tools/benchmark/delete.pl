use strict;
use warnings;
use Benchmark qw/cmpthese/;
use Blosxom::Header::Adapter;

my %header;
my $header = Blosxom::Header::Adapter->TIEHASH( \%header );

my @headers = (
    -type       => 'text/plain',
    -charset    => 'utf-8',
    -attachment => 'genome.jpg',
    -foo        => 'bar',
);

cmpthese(-1, {
    'Content-Type' => sub {
        %header = @headers;
        $header->DELETE('Content-Type');
    },
    'Content-Disposition' => sub {
        %header = @headers;
        $header->DELETE('Content-Disposition');
    },
    'Foo' => sub {
        %header = @headers;
        $header->DELETE('Foo');
    },
});

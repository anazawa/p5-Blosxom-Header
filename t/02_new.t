use strict;
use Test::More tests => 2;
use Test::Warn;
use Blosxom::Header;

{
    package blosxom;
    our $header;
}

warning_is { Blosxom::Header->new() }
    { carped => q{$blosxom::header hasn't been initialized yet.} };

$blosxom::header = {
    -type => 'text/html',
};

{
    my $header = Blosxom::Header->new();
}

is_deeply($blosxom::header, {
    '-type' => 'text/html',
});

#{
#    my $header = Blosxom::Header->new(
#        'Content-Type' => 'text/plain',
#        'Status'       => '304 Not Modified',
#    );
#}

#is_deeply($blosxom::header, {
#    '-type'   => 'text/plain',
#    '-Status' => '304 Not Modified',
#});


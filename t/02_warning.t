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

$blosxom::header = {};
my $header = Blosxom::Header->new();
$header->set( 'Status' => '123' );

warning_is { $header->DESTROY }
    { carped => q{Unknown status code: 123} };

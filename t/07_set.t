use strict;
use warnings;
use Test::More tests => 5;
use Blosxom::Header;

{
    package blosxom;
    our $header;
}

my $header = Blosxom::Header->new();

$header->set( 'type' => 'text/html;' );
is($header->get('type'),  'text/html;');

# Override
$header->set( 'type' => 'text/plain;' );
is($header->get('type'), 'text/plain;');

$header->remove_all();
$header->set(
    type          => 'text/html;',
    status        => '304',
    cache_control => 'must-revalidate',
);
is($header->get('type'),          'text/html;'      );
is($header->get('cache_control'), 'must-revalidate' );
is($header->get('status'),        '304 Not Modified');


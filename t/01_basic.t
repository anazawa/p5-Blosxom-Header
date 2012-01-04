use strict;
use Test::More tests => 8;
use Blosxom::Header;

{
    package blosxom;

    our $header = {
        -type          => 'text/html;',
        -Status        => '304 Not Modified',
        '-Cache-Control' => 'must-revalidate',
    };
}

{
    my $header  = Blosxom::Header->new();
    my @methods = qw(new remove set DESTROY);

    isa_ok($header, 'Blosxom::Header');
    can_ok($header,  @methods);
    is($header->{'Content-Type'}, 'text/html;');
    is(exists $header->{'Content-Type'}, 1);
    is(exists $header->{'Content-Length'}, q{});
    $header->set( 'Content-Length' => '1234' );
}

{
    my $expected = {
        '-Content-Type'           => 'text/html;',
        '-Status'         => '304 Not Modified',
        '-Cache-Control'  => 'must-revalidate',
        '-Content-Length' => '1234',
    };

    is_deeply($blosxom::header, $expected);
}

# override
{
    my $header = Blosxom::Header->new();
    $header->set(
        'Content-Type'   => 'text/plain;',
        'Status' => '404',
    );
}

{
    my $expected = {
        '-Content-Type'           => 'text/plain;',
        '-Status'         => '404 Not Found',
        '-Cache-Control'  => 'must-revalidate',
        '-Content-Length' => '1234',
    };

    is_deeply($blosxom::header, $expected);
}

# Blosxom::Header->remove()
{
    my $header = Blosxom::Header->new();
    $header->remove('Cache-Control', 'Content-Length');
}

{
    my $expected = {
        '-Content-Type'   => 'text/plain;',
        -Status => '404 Not Found',
    };

    is_deeply($blosxom::header, $expected);
}


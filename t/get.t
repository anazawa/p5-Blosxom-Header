use strict;
use Test::More tests => 3;
use Blosxom::Header;

BEGIN {
    package blosxom;

    our $header = {
        -type => 'text/html',
    };
}

#warn __PACKAGE__;

{
    my $header = Blosxom::Header->new();
    is($header->get('Content-Type'), 'text/html');
    is($header->get('Content-Length'), undef);
    #isa_ok($header, 'Blosxom::Header');
    #can_ok($header, qw/new remove set DESTROY/);
    #is_deeply($header, {'Content-Type' => 'text/html'});

    #$header->{'Content-Length'} = '1234';
}

is_deeply($blosxom::header, {
    '-type'   => 'text/html',
});

# override
#{
#    my $header = Blosxom::Header->new();
#    $header->{'Content-Type'} = 'text/plain';

#    is_deeply($header, {
#        'Content-Type'   => 'text/plain',
#        'Content-Length' => '1234',
#    });
#}

#is_deeply($blosxom::header, {
#    '-Content-Type'   => 'text/plain',
#    '-Content-Length' => '1234',
#});

#{
#    my $header = Blosxom::Header->new();
#    delete $header->{'Content-Length'};

#    is_deeply($header, {'Content-Type' => 'text/plain'});
#}

#is_deeply($blosxom::header, {
#    '-Content-Type' => 'text/plain',
#});

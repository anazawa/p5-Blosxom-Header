use strict;
use Blosxom::Header;
use CGI::Cookie;
use Test::More tests => 10;

my %header;

{
    package blosxom;
    our $header = \%header;
}

my $header = Blosxom::Header->instance;

%header = ();
$header->cookie( foo => 'bar' );
my $got = $header{-cookie};
isa_ok $got, 'CGI::Cookie';
is $got->value, 'bar';

%header = ();
$header->cookie( foo => { value => 'bar' } );
$got = $header{-cookie};
isa_ok $got, 'CGI::Cookie';
is $got->value, 'bar';

my $cookie1 = CGI::Cookie->new(
    -name  => 'foo',
    -value => 'bar',
);

my $cookie2 = CGI::Cookie->new(
    -name  => 'bar',
    -value => 'baz',
);

%header = ( -cookie => $cookie1 );
$got = $header->cookie( 'foo' );
isa_ok $got, 'CGI::Cookie';
is $got->value, 'bar';
is_deeply [ $header->cookie ], [ 'foo' ];

%header = ( -cookie => [ $cookie1, $cookie2 ] );
$got = $header->cookie( 'bar' );
isa_ok $got, 'CGI::Cookie';
is $got->value, 'baz';
is_deeply [ sort $header->cookie ], [ 'bar', 'foo' ];

%header = ();
is $header->push_cookie( foo => 'bar' ), 1;
$got = $header->cookie( 'foo' );
isa_ok $got, 'CGI::Cookie';
is $got->value, 'bar';

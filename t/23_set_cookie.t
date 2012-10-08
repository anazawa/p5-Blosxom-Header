use strict;
use Blosxom::Header;
use CGI::Cookie;
use Test::More tests => 2;

$blosxom::header = {};
my $header = Blosxom::Header->instance;

subtest 'get_cookie()' => sub {
    my $cookie1 = CGI::Cookie->new(
        -name  => 'foo',
        -value => 'bar',
    );

    my $cookie2 = CGI::Cookie->new(
        -name  => 'bar',
        -value => 'baz',
    );

    $header->{Set_Cookie} = $cookie1;
    is $header->get_cookie('foo'), $cookie1;
    is $header->get_cookie('bar'), undef;

    $header->{Set_Cookie} = [ $cookie1, $cookie2 ];
    is $header->get_cookie('foo'), $cookie1;
    is $header->get_cookie('bar'), $cookie2;
    is $header->get_cookie('baz'), undef;
};

subtest 'set_cookie()' => sub {
    delete $header->{Set_Cookie};
    $header->set_cookie( foo => 'bar' );
    my $got = $header->{Set_Cookie}[0];
    isa_ok $got, 'CGI::Cookie';
    is $got->name, 'foo';
    is $got->value, 'bar';

    delete $header->{Set_Cookie};
    $header->set_cookie( foo => { value => 'bar' } );
    $got = $header->{Set_Cookie}[0];
    isa_ok $got, 'CGI::Cookie';
    is $got->name, 'foo';
    is $got->value, 'bar';

    my $cookie = CGI::Cookie->new(
        -name  => 'foo',
        -value => 'bar',
    );

    $header->{Set_Cookie} = $cookie;
    $header->set_cookie( foo => 'baz' );
    $got = $header->{Set_Cookie}[0];
    isa_ok $got, 'CGI::Cookie';
    is $got->name, 'foo';
    is $got->value, 'baz';

    $cookie = CGI::Cookie->new(
        -name  => 'foo',
        -value => 'bar',
    );

    $header->{Set_Cookie} = $cookie;
    $header->set_cookie( foo => { value => 'baz' } );
    $got = $header->{Set_Cookie}[0];
    isa_ok $got, 'CGI::Cookie';
    is $got->name, 'foo';
    is $got->value, 'baz';
};

#use Data::Dumper;
#warn Dumper(\@Blosxom::Header::ISA);
$header->DESTROY;

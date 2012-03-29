use strict;
use Blosxom::Header;
use Test::More;

{
    package blosxom;
    our $header;
}

{
    undef $blosxom::header;
    eval { Blosxom::Header->new };
    like $@, qr{^Must pass a reference to hash\.};
}

{
    undef $blosxom::header;
    my $header_ref = {};
    my $h = Blosxom::Header->new( $header_ref );
    isa_ok $h, 'Blosxom::Header::Object';
    can_ok $h, qw( new header get set push_cookie exists delete DESTROY );
    is $h->header, $header_ref;
}

{
    $blosxom::header = {};
    my $h = Blosxom::Header->new;
    is $h->header, $blosxom::header;
}

{
    $blosxom::header = {};
    my $header_ref = {};
    my $h = Blosxom::Header->new( $header_ref );
    is   $h->header, $header_ref;
    isnt $h->header, $blosxom::header;
}

done_testing;

package Blosxom::Header::Object;
use strict;
use warnings;
use Blosxom::Header qw(get_header set_header has_header remove_header);

sub new {
    my ( $class, $header_ref ) = @_;
    return bless \$header_ref, $class;
}

sub get {
    my ( $self, $key ) = @_;
    return get_header( $$self, $key );
}

sub has {
    my ( $self, $key ) = @_;
    return has_header( $$self, $key );
}

sub remove {
    my ( $self, $key ) = @_;
    return remove_header( $$self, $key );
}

sub set {
    my ( $self, $key, $value ) = @_;
    return set_header( $$self, $key => $value );
}

1;

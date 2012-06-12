package Blosxom::Header::Proxy;
use strict;
use warnings;
use Carp qw/croak/;

# Naming conventions
#   $field : raw field name (e.g. Foo-Bar)
#   $norm  : normalized field name (e.g. -foo_bar)

sub TIEHASH {
    my ( $class, $callback ) = @_;

    # defaults to an ordinary hash
    unless ( ref $callback eq 'CODE' ) {
        $callback = sub { shift };
    }

    bless $callback, $class;
}

sub FETCH {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );
    $self->header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;
    my $norm = $self->( $field );
    $self->header->{ $norm } = $value;
    return;
}

sub DELETE {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );
    delete $self->header->{ $norm };
}

sub EXISTS {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );
    exists $self->header->{ $norm };
}

sub CLEAR { %{ shift->header } = () }

sub FIRSTKEY {
    my $header = shift->header;
    keys %{ $header };
    each %{ $header };
}

sub NEXTKEY { each %{ shift->header } }

sub SCALAR { ref $blosxom::header eq 'HASH' }

sub header {
    return $blosxom::header if SCALAR();
    croak( q{$blosxom::header hasn't been initialized yet.} );
}

1;

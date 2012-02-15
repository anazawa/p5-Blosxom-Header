package Blosxom::Header::Object;
use strict;
use warnings;
use Carp;

sub can {
    my ( $self, $method ) = @_;
    exists $self->{ $method };
}

sub AUTOLOAD {
    my ( $self, @args ) = @_;
    ( my $method = our $AUTOLOAD ) =~ s{.*::}{}o;

    return if $method eq 'DESTROY';

    unless ( $self->can( $method ) ) {
        croak qq{Can't locate object method "$method" via package } .
              __PACKAGE__;
    }

    $self->{ $method }->( @args );
}

1;

package Blosxom::Header::Object;
use strict;
use warnings;
use Blosxom::Header qw(:all);
use Carp;
use Scalar::Util qw(refaddr);

{
    my %header_of;

    sub new {
        my ( $class, $header_ref ) = @_;

        unless ( ref $header_ref eq 'HASH' ) {
            croak 'Must pass a reference to hash.';
        }

        my $self = bless \do { my $anon_scalar }, $class;
        my $id = refaddr( $self );
        $header_of{ $id } = $header_ref;
        $self;
    }

    # read only
    sub header {
        my $self = shift;
        my $id = refaddr( $self );
        $header_of{ $id };
    }

    sub get {
        my ( $self, $key ) = @_;
        get_header( $self->header, $key );
    }

    sub set {
        my ( $self, $key, $value ) = @_;
        set_header( $self->header, $key => $value );
        return;
    }

    sub push {
        my ( $self, $key, $value ) = @_;
        push_header( $self->header, $key, $value );
        return;
    }

    sub exists {
        my ( $self, $key ) = @_;
        exists_header( $self->header, $key );
    }

    sub delete {
        my ( $self, $key ) = @_;
        delete_header( $self->header, $key );
        return;
    }

    sub DESTROY {
        my $id = refaddr( shift );
        delete $header_of{ $id };
        return;
    }
}

1;

__END__

=head1 NAME

Blosxom::Header::Object - Wraps subroutines exported by Blosxom::Header in an object

=head1 SYNOPSIS

  use Blosxom::Header::Object;

  my $h     = Blosxom::Header::Object->new( $blosxom::header );
  my $value = $h->get( 'foo' );
  my $bool  = $h->exists( 'foo' );
  $h->set( 'foo' => 'bar' );
  $h->remove( 'foo' );

=head1 DESCRIPTION

Wraps subroutines exported by Blosxom::Header in an object.

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 Ryo Anazawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

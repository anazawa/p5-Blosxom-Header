package Blosxom::Header::Class;
use strict;
use warnings;
use Blosxom::Header;

sub new {
    my $class      = shift;
    my $header_ref = shift || $blosxom::header;
        
    unless ( ref $header_ref eq 'HASH' ) {
        require Carp;
        Carp::croak( 'Must pass a reference to hash.' );
    }

    bless { header => $header_ref }, $class;
}

sub get {
    my ( $self, $key ) = @_;
    Blosxom::Header::get_header( $self->{header}, $key );
}

sub set {
    my ( $self, $key, $value ) = @_;
    Blosxom::Header::set_header( $self->{header}, $key => $value );
    return;
}
 
sub exists {
    my ( $self, $key ) = @_;
    Blosxom::Header::exists_header( $self->{header}, $key );
}

sub delete {
    my ( $self, $key ) = @_;
    Blosxom::Header::delete_header( $self->{header}, $key );
    return;
}

sub push_cookie {
    my ( $self, $key, $value ) = @_;
    Blosxom::Header::push_cookie( $self->{header}, $key, $value );
    return;
}

1;

__END__

=head1 NAME

Blosxom::Header::Object - Wraps subroutines exported by Blosxom::Header in an object

=head1 SYNOPSIS

  require Blosxom::Header::Object;

  my $h     = Blosxom::Header::Object->new( $blosxom::header );
  my $value = $h->get( 'foo' );
  my $bool  = $h->exists( 'foo' );

  $h->set( foo => 'bar' );
  $h->delete( 'foo' );

  my @cookies = $h->get( 'Set-Cookie' );
  $h->push_cookie( 'foo' );

  $h->header; # same reference as $blosxom::header

=head1 DESCRIPTION

Wraps subroutines exported by Blosxom::Header in an object.

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011-2012 Ryo Anazawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

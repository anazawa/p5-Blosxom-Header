package Blosxom::Header::Class;
use strict;
use warnings;
use Blosxom::Header;
use Carp;
use Scalar::Util qw(refaddr);

{
    my %header_of;

    sub new {
        my $class = shift;
        my $header_ref = shift || $blosxom::header;
        croak 'Not a HASH reference' unless ref $header_ref eq 'HASH';
        my $self = bless \do { my $anon_scalar }, $class;
        $header_of{ refaddr $self } = $header_ref;
        $self;
    }

    sub header { $header_of{ refaddr shift } }

    sub DESTROY { delete $header_of{ refaddr shift } }

    sub get {
        my $header_ref = $header_of{ refaddr shift };
        Blosxom::Header::get_header( $header_ref, @_ );
    }

    sub set {
        my $header_ref = $header_of{ refaddr shift };
        Blosxom::Header::set_header( $header_ref, @_ );
    }

    sub exists {
        my $header_ref = $header_of{ refaddr shift };
        Blosxom::Header::exists_header( $header_ref, @_ );
    }

    sub delete {
        my $header_ref = $header_of{ refaddr shift };
        Blosxom::Header::delete_header( $header_ref, @_ );
    }

    sub push {
        my $header_ref = $header_of{ refaddr shift };
        Blosxom::Header::push_header( $header_ref, @_ );
    }
}

1;

__END__

=head1 NAME

Blosxom::Header::Class - Provides OO interface

=head1 SYNOPSIS

  {
      package blosxom;
      our $header = { -type => 'text/html' };
  }

  require Blosxom::Header::Class;

  my $h     = Blosxom::Header::Class->new;
  my $value = $h->get( 'foo' );
  my $bool  = $h->exists( 'foo' );

  $h->set( foo => 'bar' );
  $h->delete( 'foo' );

  my @cookies = $h->get( 'Set-Cookie' );
  $h->push( 'Set-Cookie', 'foo' );

  $h->{header}; # same reference as $blosxom::header

=head1 DESCRIPTION

Provides OO interface.

=head1 SEE ALSO

L<Blosxom::Header>

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

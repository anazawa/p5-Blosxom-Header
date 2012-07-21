package Blosxom::Header::Iterator;
use strict;
use warnings;
use Carp qw/croak/;

sub new {
    my ( $class, $iteratee ) = @_;
    croak( 'Not a hash reference' ) unless ref $iteratee eq 'HASH';
    bless { iteratee => $iteratee }, $class;
}

sub initialize {
    my $self = shift;

    my @fields;

    my %header = %{ $self->{iteratee} };
    delete $header{-charset};

    push @fields, 'Status'        if delete $header{-status};
    push @fields, 'Window-Target' if delete $header{-target};
    push @fields, 'P3P'           if delete $header{-p3p};

    push @fields, 'Set-Cookie' if my $cookie  = delete $header{-cookie};
    push @fields, 'Expires'    if my $expires = delete $header{-expires};
    push @fields, 'Date' if delete $header{-nph} || $expires || $cookie;

    push @fields, 'Content-Disposition' if delete $header{-attachment};

    # not ordered
    while ( my ($norm, $value) = each %header ) {
        next if !$value or $norm eq '-type';
        push @fields, $self->denormalize( $norm );
    }

    if ( !exists $header{-type} or delete $header{-type} ) {
        push @fields, 'Content-Type';
    }

    $self->{collection} = \@fields;
    $self->{size}       = scalar @fields;
    $self->{current}    = 0;

    $self;
}

sub next {
    my $self = shift;
    return unless $self->has_next;
    $self->{collection}->[ $self->{current}++ ];
}

sub has_next {
    my $self = shift;
    $self->{current} < $self->{size};
}

sub size    { shift->{size}    }
sub current { shift->{current} }

sub denormalize {
    my ( $self, $norm ) = @_;

    # get rid of an initial dash
    ( my $field = $norm ) =~ s/^-//;

    # transliterate underbars into dashes
    $field =~ tr/_/-/;

    ucfirst $field;
}

1;

__END__

=head1 NAME

Blosxom::Header::Iterator

=head1 SYNOPSIS

  use Blosxom::Header::Iterator;

  my %header = ( -type => 'text/plain' );
  my $iterator = Blosxom::Header::Iterator->new( \%header );

  $header{-cookie} = 'foo';

  $iterator->initialize;

  while ( $iterator->has_next ) {
      my $field = $iterator->next;
      print "$field\n";
  }

=head1 METHODS

=over 4

=item $iterator = Blosxom::Header::Iterator->new( HashRef )

Creates a new Blosxom::Header::Iterator object.

=item $iterator->initialize

Executes all startup work required before iteration.

=item $bool = $iterator->has_next

=item $field = $iterator->next

Increments the iterator and returns the new value.

=item $field = $iterator->denormalize( $norm )

=back

=head1 MAINTAINER

Ryo Anazawa

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

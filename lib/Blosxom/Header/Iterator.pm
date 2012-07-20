package Blosxom::Header::Iterator;
use strict;
use warnings;

sub new {
    my ( $class, %args ) = @_;
    my $iteratee = delete $args{collection};
    bless { iteratee => $iteratee }, $class;
}

sub initialize {
    my $self   = shift;
    my %header = %{ $self->{iteratee} };

    my @fields;

    push @fields, 'Status'        if delete $header{-status};
    push @fields, 'Window-Target' if delete $header{-target};
    push @fields, 'P3P'           if delete $header{-p3p};

    push @fields, 'Set-Cookie' if my $cookie  = delete $header{-cookie};
    push @fields, 'Expires'    if my $expires = delete $header{-expires};
    push @fields, 'Date'       if delete $header{-nph} || $expires || $cookie;

    push @fields, 'Content-Disposition' if delete $header{-attachment};

    while ( my ($norm, $value) = each %header ) {
        next if !$value or $norm eq '-type' or $norm eq '-charset';
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

sub reset { shift->{current} = 0 }

sub denormalize {
    my ( $self, $norm ) = @_;
    $norm =~ s/^-//;
    $norm =~ tr/_/-/;
    ucfirst $norm;
}

1;

__END__

=head1 NAME

Blosxom::Header::Iterator

=head1 SYNOPSIS

  use Blosxom::Header::Iterator;
  use CGI qw/header/;

  my %header = ( -type => 'text/plain' );
  my $iterator = Blosxom::Header::Iterator->new( collection => \%header );

  $header{-cookie} = 'foo';

  $iterator->initialize;
  while ( $iterator->has_next ) {
      my $field = $iterator->next;
      print "$field\n";
  }

=head1 METHODS

=over 4

=item $iterator = Blosxom::Header::Iterator->new( collection => {} )

=item $iterator->initialize

=item $bool = $iterator->has_next

=item $field = $iterator->next

=item $iterator->reset

=item $field = $iterator->denormalize( $norm )

=back

=head1 MAINTAINER

Ryo Anazawa

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

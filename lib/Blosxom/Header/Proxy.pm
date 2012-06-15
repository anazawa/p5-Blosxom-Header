package Blosxom::Header::Proxy;
use strict;
use warnings;
use constant NOT_INITIALIZED => q{$blosxom::header hasn't been initialized yet.};
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
    croak( NOT_INITIALIZED ) unless is_initialized();
    my $norm = $self->( $field );
    $blosxom::header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;
    croak( NOT_INITIALIZED ) unless is_initialized();
    my $norm = $self->( $field );
    $blosxom::header->{ $norm } = $value;
    return;
}

sub DELETE {
    my ( $self, $field ) = @_;
    croak( NOT_INITIALIZED ) unless is_initialized();
    my $norm = $self->( $field );
    delete $blosxom::header->{ $norm };
}

sub EXISTS {
    my ( $self, $field ) = @_;
    croak( NOT_INITIALIZED ) unless is_initialized();
    my $norm = $self->( $field );
    exists $blosxom::header->{ $norm };
}

sub CLEAR {
    croak( NOT_INITIALIZED ) unless is_initialized();
    %{ $blosxom::header } = ();
}

sub FIRSTKEY {
    croak( NOT_INITIALIZED ) unless is_initialized();
    keys %{ $blosxom::header };
    each %{ $blosxom::header };
}

sub NEXTKEY {
    croak( NOT_INITIALIZED ) unless is_initialized();
    each %{ $blosxom::header }
}

sub SCALAR { is_initialized() and %{ $blosxom::header } }

sub is_initialized { ref $blosxom::header eq 'HASH' }

1;

__END__

=head1 NAME

Blosxom::Header::Proxy

=head1 SYNOPSIS

  use Blosxom::Header::Proxy;

  # Ordinary hash
  my $proxy = tie my %proxy => 'Blosxom::Header::Proxy';
  my $value = $proxy{Foo}; # same value as $blosxom::header->{Foo}

  # Insensitive hash
  my $callback = sub { lc shift };
  my $proxy = tie my %proxy => 'Blosxom::Header::Proxy', $callback;
  my $value = $proxy{Foo}; # same value as $blosxom::header->{foo}

  undef $blosxom::header;
  my $bool = %proxy; # false
  $proxy->header; # throws an exception

  $blosxom::header = {};
  my $bool = %proxy; # true
  my $hashref = $proxy->header; # same reference as $blosxom::header

=head1 DESCRIPTION

=over 4

=item $proxy = tie %proxy => 'Blosxom::Header::Proxy', $callback

Associates a new hash instance with Blosxom::Header::Proxy.
$callback normalizes hash keys passed to %proxy (defaults to C<sub { shift }>).

=item $bool = %proxy

A shortcut for

  $bool = ref $blosxom::header eq 'HASH';

=item $hashref = $proxy->header

Returns the same reference as C<$blosxom::header>.
If C<scalar %proxy> is false, throws an exception.

=back

=head1 SEE ALSO

L<Blosxom::Header>,
L<perltie>

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

package Blosxom::Header::Proxy;
use strict;
use warnings;
use Carp qw/croak/;

# Naming conventions
#   $field : raw field name (e.g. Foo-Bar)
#   $norm  : normalized field name (e.g. -foo_bar)

sub TIEHASH {
    my $class = shift;

    my %alias_of = (
        -content_type => '-type',
        -cookies      => '-cookie',
        -set_cookie   => '-cookie',
        -window_target => '-target',
    );

    my $self = sub {
        # lowercase a given string
        my $norm  = lc shift;

        # add an initial dash if not exist
        $norm = "-$norm" unless $norm =~ /^-/;

        # transliterate dashes into underscores in field names
        substr( $norm, 1 ) =~ tr{-}{_};

        $alias_of{ $norm } || $norm;
    };

    bless $self, $class;
}

sub FETCH {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );

    if ( $norm eq '-type' ) {
        my $type = $self->header->{-type};
        my $charset = $self->header->{-charset};

        if ( defined $type and $type eq q{} ) {
            return;
        }

        if ( !defined $type and !defined $charset ) {
            return 'text/html; charset=ISO-8859-1';
        }

        if ( !$charset and $type ) {
            return $type if $type =~ /\bcharset\b/;
            return "$type; charset=ISO-8859-1";
        }

        if ( !defined $type ) {
            return 'text/html' if $charset eq q{};
            return "text/html; charset=$charset";
        }

        if ( $type and $type =~ /\bcharset\b/ ) {
            return $type;
        }

        return "$type; charset=$charset";
    }

    if ( $norm eq '-content_disposition' ) {
        my $attachment = $self->header->{-attachment};
        return qq{attachment; filename="$attachment"} if $attachment;
    }

    $self->header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;
    my $norm = $self->( $field );

    if ( $norm eq '-content_disposition' ) {
        delete $self->header->{-attachment};
    }

    if ( $norm eq '-attachment' ) {
        delete $self->header->{-content_disposition};
    }

    $self->header->{ $norm } = $value;
    return;
}

sub DELETE {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );

    if ( $norm eq '-type' ) {
        delete $self->header->{-charset};
        $self->header->{-type} = q{};
        return;
    }

    if ( $norm eq '-content_disposition' ) {
        delete $self->header->{-attachment};
    }

    delete $self->header->{ $norm };
}

sub EXISTS {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );

    if ( $norm eq '-type' ) {
        return 1 unless exists $self->header->{-type};
        return $self->header->{-type} ne q{};
    }

    if ( $norm eq '-content_disposition' ) {
        return 1 if $self->header->{-attachment};
    }

    exists $self->header->{ $norm };
}

#sub CLEAR { %{ shift->header } = () }
sub CLEAR { %{ shift->header } = ( -type => q{} ) }

my %field_name_of = (
    -type       => 'Content-Type',
    -attachment => 'Content-Disposition',
    -status     => 'Status',
    -cookie     => 'Set-Cookie',
    -target     => 'Window-Target',
    -p3p        => 'P3P',
);

my $others = sub {
    my $field_name = shift;
    $field_name =~ s/^-//;
    $field_name =~ tr/_/-/;
    ucfirst $field_name;
};

sub FIRSTKEY {
    my $header = shift->header;
    my @keys = keys %{ $header };
    #keys %{ $header };

    return $field_name_of{-type} unless @keys;

    my $norm = each %{ $header };
    $norm = each %{ $header } if @keys > 1 and $norm and $norm eq '-type';
    #$norm = each %{ $header } if $norm and $norm eq '-charset';

    if ( $norm and $norm eq '-charset' ) {
        $norm = each %{ $header };
        return 'Content-Type' unless $norm;
    }

    if ( $norm and $norm eq '-nph' ) {
        $norm = each %{ $header };
        return 'Content-Type' unless $norm;
    }

    return if $norm and $norm eq '-type' and $header->{-type} eq q{};
    return unless $norm;
    $field_name_of{ $norm } || $others->( $norm );
}

#sub NEXTKEY { each %{ shift->header } }

sub NEXTKEY {
    my ( $self, $lastkey ) = @_;
    return if $lastkey and $lastkey eq 'Content-Type';
    my $norm = each %{ $self->header };

    $norm = each %{ $self->header } if $norm and $norm eq '-type';
    $norm = each %{ $self->header } if $norm and $norm eq '-charset';
    $norm = each %{ $self->header } if $norm and $norm eq '-nph';

    my $type = $self->header->{-type};
    return if !defined $norm and defined $type and $type eq q{};
    return 'Content-Type' unless defined $norm;

    $field_name_of{ $norm } || $others->( $norm );
}

#sub SCALAR { is_initialized() and %{ $blosxom::header } }
sub SCALAR {
    if ( is_initialized() ) {
        my @keys = keys %{ $blosxom::header };
        my $type = $blosxom::header->{-type};
        return 0 if @keys == 1 and defined $type and $type eq q{};
    }
    1;
}

sub is_initialized { ref $blosxom::header eq 'HASH' }

sub header {
    return $blosxom::header if is_initialized();
    croak( q{$blosxom::header hasn't been initialized yet.} );
}

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
  scalar %proxy;          # false
  $proxy->is_initialized; # false

  $blosxom::header = {};
  scalar %proxy;          # false
  $proxy->is_initialized; # true

  $blosxom::header = { -type => 'text/html' };
  scalar %proxy;          # true
  $proxy->is_initialized; # true

=head1 DESCRIPTION

=over 4

=item $proxy = tie %proxy => 'Blosxom::Header::Proxy', $callback

Associates a new hash instance with Blosxom::Header::Proxy.
$callback normalizes hash keys passed to %proxy (defaults to C<sub { shift }>).

=item $bool = %proxy

A shortcut for

  $bool = ref $blosxom::header eq 'HASH' and %{ $blosxom::header };

=item $bool = $proxy->is_initialized

A shortcut for

  $bool = ref $blosxom::header eq 'HASH';

=item $hashref = $proxy->header

Returns the same reference as $blosxom::header. If
C<< $proxy->is_initialized >> is false, throws an exception.

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

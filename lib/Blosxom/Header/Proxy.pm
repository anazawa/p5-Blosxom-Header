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
        -content_type  => '-type',
        -cookies       => '-cookie',
        -set_cookie    => '-cookie',
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

    my $header = $self->header;
    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        my ( $type, $charset ) = @{ $header }{qw/-type -charset/};

        if ( defined $type and $type eq q{} ) {
            undef $charset;
            undef $type;
        }
        elsif ( !defined $type ) {
            $type    = 'text/html';
            $charset = 'ISO-8859-1' unless defined $charset;
        }
        elsif ( $type =~ /\bcharset\b/ ) {
            undef $charset;
        }
        elsif ( !defined $charset ) {
            $charset = 'ISO-8859-1';
        }

        return $charset ? "$type; charset=$charset" : $type;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $attachment = $header->{-attachment};
        return qq{attachment; filename="$attachment"} if $attachment;
    }

    $header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;

    my $header = $self->header;
    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        if ( $value =~ /\bcharset\b/ ) {
            delete $header->{-charset};
        }
        else {
            $header->{-charset} = q{};
        }
    }
    elsif ( $norm eq '-content_disposition' ) {
        delete $header->{-attachment};
    }
    elsif ( $norm eq '-attachment' ) {
        delete $header->{-content_disposition};
    }

    $header->{ $norm } = $value;

    return;
}

sub DELETE {
    my ( $self, $field ) = @_;
    
    my $header = $self->header;
    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        my $deleted = $self->FETCH( 'Content-Type' );
        delete $header->{-charset};
        $header->{-type} = q{};
        return $deleted;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $deleted = $self->FETCH( 'Content-Disposition' );
        delete $header->{-attachment};
        return $deleted;
    }

    delete $header->{ $norm };
}

sub EXISTS {
    my ( $self, $field ) = @_;

    my $header = $self->header;
    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        my $type = $header->{-type};
        return ( $type or !defined $type );
    }
    elsif ( $norm eq '-content_disposition' ) {
        return 1 if $header->{-attachment};
    }

    exists $header->{ $norm };
}

sub CLEAR { %{ shift->header } = ( -type => q{} ) }

sub FIRSTKEY {
    my $header = shift->header;
    keys %{ $header };
    each %{ $header };
}

sub NEXTKEY { each %{ shift->header } }

sub SCALAR {
    my $header = shift->header;
    return 1 unless %{ $header };

    my %header = %{ $header }; # copy
    my $type = delete $header{-type};
    return 1 if $type or !defined $type;

    delete $header{-charset};
    for my $value ( values %header ) {
        return 1 if $value;
    }

    0;
}

sub field_names {
    my $self = shift;

    my %header = %{ $self->header }; # copy
    delete @header{qw/-charset -type -nph/};

    my @fields = grep { $header{ $_ } } keys %header;
    @fields = map { _field_name_of( $_ ) } @fields;
    push @fields, 'Content-Type' if $self->EXISTS( 'Content-Type' );

    @fields;
}

{
    my %field_name_of = (
        -attachment => 'Content-Disposition',
        -status     => 'Status',
        -cookie     => 'Set-Cookie',
        -target     => 'Window-Target',
        -p3p        => 'P3P',
        -expires    => 'Expires',
    );

    sub _field_name_of {
        my $norm = shift;
        return $field_name_of{ $norm } if exists $field_name_of{ $norm };
        $norm =~ s/^-//;
        $norm =~ tr/_/-/;
        ucfirst $norm;
    }
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

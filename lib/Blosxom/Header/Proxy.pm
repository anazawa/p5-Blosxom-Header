package Blosxom::Header::Proxy;
use strict;
use warnings;
use Carp qw/croak/;

our $Header;
*Header = \$blosxom::header;

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

    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        my ( $type, $charset ) = @{ $Header }{qw/-type -charset/};

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
        my $attachment = $Header->{-attachment};
        return qq{attachment; filename="$attachment"} if $attachment;
    }

    $Header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;

    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        if ( $value =~ /\bcharset\b/ ) {
            delete $Header->{-charset};
        }
        else {
            $Header->{-charset} = q{};
        }
    }
    elsif ( $norm eq '-content_disposition' ) {
        delete $Header->{-attachment};
    }
    elsif ( $norm eq '-attachment' ) {
        delete $Header->{-content_disposition};
    }

    $Header->{ $norm } = $value;

    return;
}

sub DELETE {
    my ( $self, $field ) = @_;
    
    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        my $deleted = $self->FETCH( 'Content-Type' );
        delete $Header->{-charset};
        $Header->{-type} = q{};
        return $deleted;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $deleted = $self->FETCH( 'Content-Disposition' );
        delete $Header->{-attachment};
        return $deleted;
    }

    delete $Header->{ $norm };
}

sub EXISTS {
    my ( $self, $field ) = @_;

    my $norm = $self->( $field );

    if ( $norm eq '-type' and $field =~ /content/i ) {
        my $type = $Header->{-type};
        return ( $type or !defined $type );
    }
    elsif ( $norm eq '-content_disposition' ) {
        return 1 if $Header->{-attachment};
    }

    exists $Header->{ $norm };
}

sub CLEAR { %{ $Header } = ( -type => q{} ) }

sub FIRSTKEY {
    keys %{ $Header };
    each %{ $Header };
}

sub NEXTKEY { each %{ $Header } }

sub SCALAR {
    return 1 unless %{ $Header };

    my %header = %{ $Header }; # copy
    my ( $type ) = delete @header{ '-type', '-charset' };
    return 1 if $type or !defined $type;

    for my $value ( values %header ) {
        return 1 if $value;
    }

    0;
}

sub field_names {
    my $self = shift;

    my %header = %{ $Header }; # copy
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

sub is_initialized { ref $Header eq 'HASH' }

1;

__END__

=head1 NAME

Blosxom::Header::Proxy

=head1 SYNOPSIS

  use Blosxom::Header::Proxy;

  my $proxy = tie my %proxy => 'Blosxom::Header::Proxy';

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item $proxy = tie %proxy => 'Blosxom::Header::Proxy'

Associates a new hash instance with Blosxom::Header::Proxy.

=item %proxy = ()

A shortcut for

  %{ $blosxom::header } = ( -type => q{} );

=item $bool = %proxy

  $blosxom::header = { -type => q{} };
  $bool = %proxy; # false

  $blosxom::header = {};
  $bool = %proxy; # true

=item $bool = $proxy->is_initialized

A shortcut for

  $bool = ref $blosxom::header eq 'HASH';

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

package Blosxom::Header::Proxy;
use strict;
use warnings;
use Carp qw/croak/;
use List::Util qw/first/;

# Naming conventions
#   $field : raw field name (e.g. Foo-Bar)
#   $norm  : normalized field name (e.g. -foo_bar)

sub TIEHASH {
    my $class = shift;

    my %norm_of = (
        -attachment    => q{},
        -charset       => q{},
        -cookie        => q{},
        -nph           => q{},
        -set_cookie    => q{-cookie},
        -target        => q{},
        -type          => q{},
        -window_target => q{-target},
    );

    my $self = sub {
        my $field = lc shift;

        # add an initial dash if not exists
        $field = "-$field" unless $field =~ /^-/;

        # transliterate dashes into underscores in field names
        substr( $field, 1 ) =~ tr{-}{_};

        exists $norm_of{ $field } ? $norm_of{ $field } : $field;
    };

    bless $self, $class;
}

sub FETCH {
    my ( $self, $field ) = @_;
    my $norm = $self->( $field );
    return $self->content_type if $norm eq '-content_type';    
    return $self->content_disposition if $norm eq '-content_disposition';    
    $self->header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;
    my $norm = $self->( $field );
    return $self->content_type( $value ) if $norm eq '-content_type';
    delete $self->header->{-attachment} if $norm eq '-content_disposition';
    $self->header->{ $norm } = $value;
    return;
}

sub DELETE {
    my $self   = shift;
    my $norm   = $self->( shift );
    my $header = $self->header;

    if ( $norm eq '-content_type' ) {
        my $deleted = $self->content_type;
        delete $header->{-charset};
        $header->{-type} = q{};
        return $deleted;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $deleted = $self->content_disposition;
        delete $header->{-attachment};
        return $deleted;
    }

    delete $header->{ $norm };
}

sub EXISTS {
    my $self = shift;
    my $norm = $self->( shift );

    if ( $norm eq '-content_type' ) {
        my $type = $self->header->{-type};
        return ( $type or !defined $type );
    }
    elsif ( $norm eq '-content_disposition' ) {
        return 1 if $self->header->{-attachment};
    }

    exists $self->header->{ $norm };
}

sub CLEAR {
    my $self = shift;
    %{ $self->header } = ( -type => q{} );
}

{
    my %field_name_of = (
        -attachment => 'Content-Disposition',
        -cookie     => 'Set-Cookie',
        -target     => 'Window-Target',
        -p3p        => 'P3P',
    );

    my $field_name_of = sub {
        my $norm  = shift;
        my $field = $field_name_of{ $norm };
        
        if ( !$field ) {
            # get rid of an initial dash if exists
            $norm =~ s/^-//;

            # transliterate underscores into dashes
            $norm =~ tr/_/-/;

            # uppercase the first character
            $field = ucfirst $norm;
        }

        $field;
    };

    sub FIRSTKEY {
        my $self = shift;
        keys %{ $self->header };
        return 'Content-Type' if $self->EXISTS( 'Content-Type' );
        $self->NEXTKEY;
    }

    sub NEXTKEY {
        my $self = shift;

        my $norm;
        while ( my ( $key, $value ) = each %{ $self->header } ) {
            next unless $value;
            next if $key eq '-type';
            next if $key eq '-charset';
            next if $key eq '-nph';
            $norm = $key;
            last;
        }

        $norm && $field_name_of->( $norm );
    }
}

sub SCALAR {
    my $self = shift;
    my %header = %{ $self->header }; # copy
    return 1 unless %header;
    my ( $type ) = delete @header{ '-type', '-charset' };
    return 1 if $type or !defined $type; # Content-Type exists
    my $scalar = first { $_ } values %header;
    $scalar ? 1 : 0;
}

sub is_initialized { ref $blosxom::header eq 'HASH' }

sub header {
    my $self = shift;
    return $blosxom::header if $self->is_initialized;
    croak( q{$blosxom::header hasn't been initialized yet.} );
}

sub content_type {
    my $self   = shift;
    my $header = $self->header;

    if ( @_ ) {
        my $content_type = shift;
        my $has_charset = $content_type =~ /\bcharset\b/;
        delete $header->{-charset} if $has_charset;
        $header->{-charset} = q{} unless $has_charset;
        return $header->{-type} = $content_type;
    }

    my ( $type, $charset ) = @{ $header }{ '-type', '-charset' };

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

    $charset ? "$type; charset=$charset" : $type;
}

sub content_disposition {
    my $self = shift;
    my $attachment = $self->header->{-attachment};
    return qq{attachment; filename="$attachment"} if $attachment;
    $self->header->{-content_disposition};
}

sub attachment {
    my $self = shift;
    return $self->header->{-attachment} = shift if @_;
    $self->header->{-attachment};
}

sub nph {
    my $self = shift;
    return $self->header->{-nph} = shift if @_;
    $self->header->{-nph};
}

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

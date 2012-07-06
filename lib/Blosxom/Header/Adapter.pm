package Blosxom::Header::Adapter;
use strict;
use warnings;

{
    no strict 'refs';
    *EXISTS = \&FETCH;
}

sub TIEHASH {
    my $class   = shift;
    my $adaptee = ref $_[0] eq 'HASH' ? shift : {};
    my $self    = bless { adaptee => $adaptee }, $class;

    $self->{norm_of} = {
        -attachment => q{},        -charset       => q{},
        -cookie     => q{},        -nph           => q{},
        -set_cookie => q{-cookie}, -target        => q{},
        -type       => q{},        -window_target => q{-target},
    };

    $self->{field_name_of} = {
        -attachment => 'Content-Disposition', -cookie => 'Set-Cookie',
        -target     => 'Window-Target',       -type   => 'Content-Type',
        -p3p        => 'P3P',
    };

    $self;
}

sub FETCH {
    my $self    = shift;
    my $norm    = $self->normalize( shift );
    my $adaptee = $self->{adaptee};

    if ( $norm eq '-content_type' ) {
        my $type    = $adaptee->{-type};
        my $charset = $adaptee->{-charset};

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
        my $attachment = $adaptee->{-attachment};
        return qq{attachment; filename="$attachment"} if $attachment;
    }

    $adaptee->{ $norm };
}

sub STORE {
    my $self    = shift;
    my $norm    = $self->normalize( shift );
    my $value   = shift;
    my $adaptee = $self->{adaptee};

    if ( $norm eq '-content_type' ) {
        my $has_charset = $value =~ /\bcharset\b/;
        delete $adaptee->{-charset} if $has_charset;
        $adaptee->{-charset} = q{} unless $has_charset;
        $norm = '-type';
    }
    elsif ( $norm eq '-content_disposition' ) {
        delete $adaptee->{-attachment};
    }

    $adaptee->{ $norm } = $value;

    return;
}

sub DELETE {
    my $self    = shift;
    my $norm    = $self->normalize( shift );
    my $adaptee = $self->{adaptee};

    if ( $norm eq '-content_type' ) {
        my $deleted = $self->FETCH( 'Content-Type' );
        delete $adaptee->{-charset};
        $adaptee->{-type} = q{};
        return $deleted;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $deleted = $self->FETCH( 'Content-Disposition' );
        delete @{ $adaptee }{ $norm, '-attachment' };
        return $deleted;
    }

    delete $adaptee->{ $norm };
}

sub CLEAR {
    my $self = shift;
    %{ $self->{adaptee} } = ( -type => q{} );
}

sub FIRSTKEY {
    my $self = shift;
    keys %{ $self->{adaptee} };
    exists $self->{adaptee}{-type} ? $self->NEXTKEY : 'Content-Type';
};

sub NEXTKEY {
    my $self = shift;

    my $nextkey;
    while ( my ( $norm, $value ) = each %{ $self->{adaptee} } ) {
        next if !$value or $norm eq '-charset' or $norm eq '-nph';
        $nextkey = $self->denormalize( $norm );
        last;
    }

    $nextkey;
}

sub SCALAR {
    my $self = shift;
    my $scalar = $self->FIRSTKEY;
    keys %{ $self->{adaptee} } if $scalar;
    $scalar;
}

sub normalize {
    my $self    = shift;
    my $field   = lc shift;
    my $norm_of = $self->{norm_of};

    # transliterate dashes into underscores
    $field =~ tr{-}{_};

    # add an initial dash
    $field = "-$field";

    exists $norm_of->{ $field } ? $norm_of->{ $field } : $field;
}

sub denormalize {
    my $self = shift;
    my $norm = shift;
    my $field_name_of = $self->{field_name_of};

    return $field_name_of->{ $norm } if exists $field_name_of->{ $norm };
        
    # get rid of an initial dash
    ( my $field = $norm ) =~ s/^-//;

    # transliterate underscores into dashes
    $field =~ tr/_/-/;

    # uppercase the first character
    $field_name_of->{ $norm } = ucfirst $field;
}

sub attachment {
    my $adaptee = shift->{adaptee};
    return $adaptee->{-attachment} = shift if @_;
    $adaptee->{-attachment};
}

sub nph {
    my $adaptee = shift->{adaptee};
    return $adaptee->{-nph} = shift if @_;
    $adaptee->{-nph};
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

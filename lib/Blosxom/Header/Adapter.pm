package Blosxom::Header::Adapter;
use strict;
use warnings;
use base 'Blosxom::Header::Entity';

{
    no strict 'refs';
    *TIEHASH = __PACKAGE__->can( 'new' );
    *EXISTS = \&FETCH;
}

sub FETCH {
    my $self   = shift;
    my $norm   = $self->{normalize}->( shift );
    my $header = $self->{header} || $self->header;

    if ( $norm eq '-content_type' ) {
        my $type    = $header->{-type};
        my $charset = $header->{-charset};

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
    my $self   = shift;
    my $norm   = $self->{normalize}->( shift );
    my $value  = shift;
    my $header = $self->{header} || $self->header;

    if ( $norm eq '-content_type' ) {
        my $has_charset = $value =~ /\bcharset\b/;
        delete $header->{-charset} if $has_charset;
        $header->{-charset} = q{} unless $has_charset;
        $norm = '-type';
    }
    elsif ( $norm eq '-content_disposition' ) {
        delete $header->{-attachment};
    }

    $header->{ $norm } = $value;

    return;
}

sub DELETE {
    my $self   = shift;
    my $norm   = $self->{normalize}->( shift );
    my $header = $self->{header} || $self->header;

    if ( $norm eq '-content_type' ) {
        my $deleted = $self->FETCH( $norm );
        delete $header->{-charset};
        $header->{-type} = q{};
        return $deleted;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $deleted = $self->FETCH( $norm );
        delete @{ $header }{ '-attachment', $norm };
        return $deleted;
    }

    delete $header->{ $norm };
}

sub CLEAR {
    my $self = shift;
    %{ $self->{header} || $self->header } = ( -type => q{} );
}

sub FIRSTKEY {
    my $self = shift;
    my $header = $self->{header} || $self->header;
    keys %{ $header };
    exists $header->{-type} ? $self->NEXTKEY : 'Content-Type';
};

sub NEXTKEY {
    my $self   = shift;
    my $header = $self->{header} || $self->header;

    my $nextkey;
    while ( my ( $norm, $value ) = each %{ $header } ) {
        next if !$value or $norm eq '-charset' or $norm eq '-nph';
        $nextkey = $self->{denormalize}->( $norm );
        last;
    }

    $nextkey;
}

sub SCALAR {
    my $self = shift;
    my $scalar = $self->FIRSTKEY;
    keys %{ $self->{header} || $self->header } if $scalar;
    $scalar;
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

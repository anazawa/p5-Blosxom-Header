package Blosxom::Header::Proxy;
use strict;
use warnings;
use base qw/Blosxom::Header::Normalizer/;
use Blosxom::Header::Iterator;
use Carp qw/croak/;

sub is_initialized { ref $blosxom::header eq 'HASH' }

sub header {
    my $class = shift;
    return $blosxom::header if $class->is_initialized;
    croak( q{$blosxom::header hasn't been initialized yet.} );
}

# Creates function aliases
{
    no strict 'refs';
    #*TIEHASH = __PACKAGE__->can( 'new' );
    *TIEHASH = \&new;
    *EXISTS = \&FETCH;
}

sub new {
    my $self = shift->SUPER::new;
    $self->{iterator} = Blosxom::Header::Iterator->new;
    $self;
}

sub FETCH {
    my ( $self, $field ) = @_;
    my $norm = $self->normalize( $field );
    return $self->content_type if $norm eq '-content_type';    
    return $self->content_disposition if $norm eq '-content_disposition';    
    $self->header->{ $norm };
}

sub STORE {
    my ( $self, $field, $value ) = @_;
    my $norm = $self->normalize( $field );
    return $self->content_type( $value ) if $norm eq '-content_type';
    return $self->content_disposition( $value ) if $norm eq '-content_disposition';
    $self->header->{ $norm } = $value;
    return;
}

sub DELETE {
    my $self   = shift;
    my $norm   = $self->normalize( shift );
    my $header = $self->header;

    if ( $norm eq '-content_type' ) {
        my $deleted = $self->content_type;
        delete $header->{-charset};
        $header->{-type} = q{};
        return $deleted;
    }
    elsif ( $norm eq '-content_disposition' ) {
        my $deleted = $self->content_disposition;
        delete @{ $header }{ '-attachment', $norm };
        return $deleted;
    }

    delete $header->{ $norm };
}

sub CLEAR {
    my $self = shift;
    %{ $self->header } = ( -type => q{} );
}

sub FIRSTKEY {
    my $self = shift;
    my $iterator = $self->{iterator};
    $iterator->initialize( $self->header );
    $iterator->next;
}

sub NEXTKEY { shift->{iterator}->next( @_ ) }

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
    my $self   = shift;
    my $header = $self->header;

    if ( @_ ) {
        $header->{-content_disposition} = shift;
        delete $header->{-attachment};
        return;
    }
    elsif ( my $attachment = $header->{-attachment} ) {
        return qq{attachment; filename="$attachment"};
    }

    $header->{-content_disposition};
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

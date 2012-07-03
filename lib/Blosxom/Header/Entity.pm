package Blosxom::Header::Entity;
use strict;
use warnings;
use Carp qw/croak/;

sub is_initialized {
    my $self = shift;
    return unless ref $blosxom::header eq 'HASH';
    $self->{header} = $blosxom::header;
}

sub header {
    my $self = shift;
    return $self->{header} if $self->is_initialized;
    croak( q{$blosxom::header hasn't been initialized yet.} );
}

sub new {
    my $self = bless {}, shift;

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

    $self->{normalize} = sub {
        my $field = lc shift;

        # add an initial dash if not exists
        $field = "-$field" unless $field =~ /^-/;

        # transliterate dashes into underscores in field names
        substr( $field, 1 ) =~ tr{-}{_};

        exists $norm_of{ $field } ? $norm_of{ $field } : $field;
    };

    my %field_name_of = (
        -attachment => 'Content-Disposition',
        -cookie     => 'Set-Cookie',
        -target     => 'Window-Target',
        -p3p        => 'P3P',
        -type => 'Content-Type',
    );

    $self->{denormalize} = sub {
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

    $self;
}

sub normalize {
    my ( $self, $field ) = @_;
    $self->{normalize}->( $field );
}

sub is_normalized {
    my ( $self, $src ) = @_;
    $self->{normalize}->( $src ) eq $src;
}

sub denormalize {
    my ( $self, $norm ) = @_;
    $self->{denormalize}->( $norm );
}

#sub content_type {
#    my $self   = shift;
#    my $header = $self->header;

#    if ( @_ ) {
#        my $content_type = shift;
#        my $has_charset = $content_type =~ /\bcharset\b/;
#        delete $header->{-charset} if $has_charset;
#        $header->{-charset} = q{} unless $has_charset;
#        return $header->{-type} = $content_type;
#    }

#    my ( $type, $charset ) = @{ $header }{ '-type', '-charset' };

#    if ( defined $type and $type eq q{} ) {
#        undef $charset;
#        undef $type;
#    }
#    elsif ( !defined $type ) {
#        $type    = 'text/html';
#        $charset = 'ISO-8859-1' unless defined $charset;
#    }
#    elsif ( $type =~ /\bcharset\b/ ) {
#        undef $charset;
#    }
#    elsif ( !defined $charset ) {
#        $charset = 'ISO-8859-1';
#    }

#    $charset ? "$type; charset=$charset" : $type;
#}

#sub content_disposition {
#    my $self   = shift;
#    my $header = $self->header;

#    if ( @_ ) {
#        $header->{-content_disposition} = shift;
#        delete $header->{-attachment};
#        return;
#    }
#    elsif ( my $attachment = $header->{-attachment} ) {
#        return qq{attachment; filename="$attachment"};
#    }

#    $header->{-content_disposition};
#}

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

sub reset_iterator { keys %{ shift->header } }

1;

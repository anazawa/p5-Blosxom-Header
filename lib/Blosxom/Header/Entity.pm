package Blosxom::Header::Entity;
use strict;
use warnings;
use Carp qw/croak/;

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
        -type       => 'Content-Type',
        -p3p        => 'P3P',
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

sub header {
    my $self = shift;
    return $self->{header} if $self->is_initialized;
    croak( q{$blosxom::header hasn't been initialized yet.} );
}

sub is_initialized {
    my $self = shift;
    return unless ref $blosxom::header eq 'HASH';
    $self->{header} = $blosxom::header;
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

sub reset_iterator { keys %{ shift->header } }

1;

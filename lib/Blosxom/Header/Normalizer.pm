package Blosxom::Header::Normalizer;
use strict;
use warnings;

# Naming conventions
#   $field : raw field name (e.g. Foo-Bar)
#   $norm  : normalized field name (e.g. -foo_bar)

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

    $self->{normalizer} = sub {
        my $field = lc shift;

        # add an initial dash if not exists
        $field = "-$field" unless $field =~ /^-/;

        # transliterate dashes into underscores in field names
        substr( $field, 1 ) =~ tr{-}{_};

        exists $norm_of{ $field } ? $norm_of{ $field } : $field;
    };

    $self;
}

sub normalize {
    my ( $self, $field ) = @_;
    $self->{normalizer}->( $field );
}

sub is_normalized {
    my ( $self, $src ) = @_;
    $self->normalize( $src ) eq $src;
}

1;

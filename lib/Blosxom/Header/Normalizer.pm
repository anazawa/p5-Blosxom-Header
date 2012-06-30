package Blosxom::Header::Normalizer;
use strict;
use warnings;

# Class method

sub new {
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

    my $normalizer = sub {
        my $field = lc shift;

        # add an initial dash if not exists
        $field = "-$field" unless $field =~ /^-/;

        # transliterate dashes into underscores in field names
        substr( $field, 1 ) =~ tr{-}{_};

        exists $norm_of{ $field } ? $norm_of{ $field } : $field;
    };

    bless $normalizer, $class;
}


# Instance methods

sub normalize     { $_[0]->( $_[1] )          }
sub is_normalized { $_[0]->( $_[1] ) eq $_[1] }

{
    my %field_name_of = (
        -attachment => 'Content-Disposition',
        -cookie     => 'Set-Cookie',
        -target     => 'Window-Target',
        -p3p        => 'P3P',
    );

    sub denormalize {
        my $self  = shift;
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
    }
}

1;

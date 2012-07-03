package Blosxom::Header::Iterator;
use strict;
use warnings;

sub new {
    my $self = bless {}, shift;

    my %field_name_of = (
        -attachment => 'Content-Disposition',
        -cookie     => 'Set-Cookie',
        -target     => 'Window-Target',
        -p3p        => 'P3P',
    );

    $self->{denormalizer} = sub {
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

}

sub reset {
    my $self = shift;
    $self->{current} = 0;
    $self;
}

sub initialize {
    my ( $self, $array_ref ) = @_;

    #my @fields;
    #my $type = $header->{-type};
    #push @fields, 'Content-Type' if !defined $type or $type;

    #for my $norm ( keys %{ $header } ) {
    #    next unless $header->{ $norm };
    #    next if $norm eq '-type';
    #    next if $norm eq '-charset';
    #    next if $norm eq '-nph';
    #    push @fields, $self->denormalize( $norm );
    #}

    #$self->field_names( \@fields );
    #$self->current( 0 );
    #$self->size( scalar @fields );
    $self->{collection} = $array_ref;

    $self;
}

sub next {
    my $self = shift;
    return if $self->{current} >= $self->{size};
    $self->{collection}->[ $self->{current}++ ];
}

{
    my %field_name_of = (
        -attachment => 'Content-Disposition',
        -cookie     => 'Set-Cookie',
        -target     => 'Window-Target',
        -p3p        => 'P3P',
    );

    sub denormalize {
        my $self = shift;
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

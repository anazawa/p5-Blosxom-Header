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

    $self;
}

sub collection {
    my $self = shift;
    return $self->{collection} = shift if @_;
    $self->{collection};
}

sub initialize {
    my ( $self, $collection ) = @_;
    $self->collection( $collection );
    keys %{ $collection };
}
            
sub next {
    my ( $self, $lastkey ) = @_;

    unless ( $lastkey ) {
        my $type = $self->collection->{-type};
        return 'Content-Type' if !defined $type or $type;
    }

    my $norm;
    while ( my ( $key, $value ) = each %{ $self->collection } ) {
        next unless $value;
        next if $key eq '-type';
        next if $key eq '-charset';
        next if $key eq '-nph';
        $norm = $key;
        last;
    }

    $norm && $self->denormalize( $norm );
}

sub denormalize {
    my ( $self, $norm ) = @_;
    $self->{denormalizer}->( $norm );
}

1;

package Blosxom::Header::Class;
use strict;
use warnings;
use Blosxom::Header;
use Carp;

# Parameters recognized by CGI::header()
use constant ATTRIBUTES
    => qw/attachment charset cookie expires nph p3p status target type/;

our $INSTANCE;

sub instance {
    my $class = shift;

    return $INSTANCE if defined $INSTANCE;

    #my %header;
    #tie %header, 'Blosxom::Header';
    tie my %header, 'Blosxom::Header';

    $INSTANCE = bless \%header, $class;
}

sub exists { exists $_[0]->{ $_[1] } }
sub clear  { %{ $_[0] } = () }

sub delete {
    my ( $self, @fields ) = @_;
    delete @{ $self }{ @fields };
}

sub get {
    my $value = $_[0]->{ $_[1] };
    return $value unless ref $value eq 'ARRAY';
    return @{ $value } if wantarray;
    return $value->[0] if defined wantarray;
    carp 'Useless use of get() in void context';
}

sub set {
    my ( $self, @fields ) = @_;

    return unless @fields;

    if ( @fields == 2 ) {
        $self->{ $fields[0] } = $fields[1];
    }
    elsif ( @fields % 2 == 0 ) {
        while ( my ( $field, $value ) = splice @fields, 0, 2 ) {
            $self->{ $field } = $value ;
        }
    }
    else {
        croak 'Odd number of elements are passed to set()';
    }

    return;
}

sub push_cookie { shift->_push( -cookie => @_ ) }
sub push_p3p    { shift->_push( -p3p    => @_ ) }

sub _push {
    my ( $self, $field, @values ) = @_;

    unless ( @values ) {
        carp 'Useless use of _push() with no values';
        return;
    }

    if ( my $value = $self->{ $field } ) {
        return push @{ $value }, @values if ref $value eq 'ARRAY';
        unshift @values, $value;
    }

    $self->{ $field } = @values > 1 ? \@values : $values[0] ;

    scalar @values if defined wantarray;
}

# make accessors
for my $attr ( ATTRIBUTES ) {
    my $slot  = __PACKAGE__ . "::$attr";
    my $field = "-$attr";

    no strict 'refs';

    *$slot = sub {
        my $self = shift;
        $self->{ $field } = shift if @_;
        $self->get( $field );
    }
}

1;

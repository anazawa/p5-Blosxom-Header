package Blosxom::Header::Proxy;
use strict;
use warnings;

# Naming conventions
#   $field : raw field name (e.g. Foo-Bar)
#   $norm  : normalized field name (e.g. -foo_bar)

sub TIEHASH {
    my ( $class, %args ) = @_;

    # defaults to an ordinary hash
    my %self = (
        hashref  => {},
        callback => sub { shift },
    );

    # Make sure keys of HASHREF are normalized
    if ( ref $args{hashref} eq 'HASH' ) {
        $self{hashref} = delete $args{hashref};
    }

    if ( ref $args{callback} eq 'CODE' ) {
        $self{callback} = delete $args{callback};
    }

    bless \%self, $class;
}

sub FETCH {
    my ( $self, $key ) = @_;
    my $norm = $self->{callback}->( $key );
    $self->{hashref}->{$norm};
}

sub STORE {
    my ( $self, $key, $value ) = @_;
    my $norm = $self->{callback}->( $key );
    $self->{hashref}->{$norm} = $value;
    return;
}

sub DELETE {
    my ( $self, $key ) = @_;
    my $norm = $self->{callback}->( $key );
    delete $self->{hashref}->{$norm};
}

sub EXISTS {
    my ( $self, $key ) = @_;
    my $norm = $self->{callback}->( $key );
    exists $self->{hashref}->{$norm};
}

sub CLEAR { %{ shift->{hashref} } = () }

sub FIRSTKEY {
    my $hashref = shift->{hashref};
    keys %{ $hashref };
    each %{ $hashref };
}

sub NEXTKEY { each %{ shift->{hashref} } }

1;

package Blosxom::Header::Iterator;
use strict;
use warnings;

sub new {
    my ( $class, $header ) = @_;
    
    my %self = %{ $header }; # copy

    while ( my ( $key, $value ) = each %self ) {
        next if $value and $key !~ /^-type|-charset|-nph$/;
        delete $self{ $key };
    }

    bless \%self, $class;
}

sub firstkey {
    my $self = shift;
    keys %{ $self };
    each %{ $self };
}

sub nextkey {
    my $self = shift;
    each %{ $self };
}

1;

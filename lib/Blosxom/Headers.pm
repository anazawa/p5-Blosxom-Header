package Blosxom::Headers;

use strict;
use warnings;
use HTTP::Status qw(status_message);
use Carp;

sub new {
    my $self    = shift;
    my %headers = @_ || ();

    if (%headers) {
        $self->remove_all();
        $self->set(%headers);
    }

    return bless \%headers, $self;
}

sub get {
    my $self = shift;
    my $key  = shift;

    return $blosxom::header->{"-$key"};
}

sub exists {
    my $self = shift;
    my $key  = shift;

    return defined $self->get($key);
}

sub remove {
    my $self    = shift;
    my @keys    = @_;
    my @deleted = ();

    for my $key (@keys) {
        if ($self->exists($key)) {
            delete $blosxom::header->{"-$key"};
            push @deleted, $key;
        }
    }

    return @deleted;
}

sub keys {
    my @keys = keys %$blosxom::header;
    for (@keys) { $_ =~ s{^-}{} }
    return @keys;
}

sub remove_all {
    my $self = shift;
    my @keys = $self->keys();

    $blosxom::header = {};

    return @keys;
}

sub set {
    my ($self, %headers) = @_;

    while (my ($key, $value) = each %headers) {
        if ($key eq 'status' and $value =~ /^\d\d\d$/) {
            if (my $message = status_message($value)) {
                $value .= " $message";
            }
            else {
                carp "Unknown status code: $value";
            }
        }

        $blosxom::header->{"-$key"} = $value;
    }

    return;
}

1;


package Blosxom::Headers;

use strict;
use warnings;
use HTTP::Status qw(status_message);
use Carp;

sub new {
    my $self = shift;
    return bless {}, $self;
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

__END__

=head1 NAME

Blosxom::Headers - Set HTTP headers in an object-oriented way

=head1 SYNOPSIS

  use Blosxom::Headers;

  my $header = Blosxom::Headers->new();
  
  $header->set(
    type          => 'text/html;',
    status        => '404',
    cache_control => 'must-revalidate',
  );

  my $value = $header->get('status');           # 404 Not Found
  my $bool  = $header->exists('cache_control'); # 1
  my @keys  = $header->keys();                  # ('type', 'status', 'cache_control')

  $header->remove('cache_control');
  @keys = $header->keys();             # ('type', 'status')
  my @deleted = $header->remove_all(); # ('type', 'status')
  @keys = $header->keys();             # ()

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item $header = Blosxom::Headers->new();

Creates a new Blosxom::Headers object.

=item $header->get('foo')

Returns a value of the specified HTTP header.

=item $header->exists('foo')

Returns a Boolean value telling whether the specified HTTP header
has a value.

=item $header->remove('foo', 'bar')

=item $header->set(%headers)

=item $header->keys()

Returns a list of all the keys of HTTP headers.

=item $header->remove_all()

=back

=head1 DIAGOSTICS

=head1 DEPENDENCIES

L<HTTP::Status>, Blosxom 2.1.2

=head1 AUTHOR

Ryo Anazawa (r-anazawa@shochutairen.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 Ryo Anazawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


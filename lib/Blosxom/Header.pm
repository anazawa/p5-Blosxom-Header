package Blosxom::Header;

use strict;
use warnings;
use HTTP::Status qw(status_message);
use Carp;

our $VERSION = '0.01';

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
    my $self = shift;
    my @keys = @_;

    for my $key (@keys) {
        if ($self->exists($key)) {
            delete $blosxom::header->{"-$key"};
        }
    }

    return;
}

sub keys {
    my @keys = keys %$blosxom::header;
    for (@keys) { $_ =~ s{^-}{} }
    return @keys;
}

sub remove_all {
    $blosxom::header = {};
    return;
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

Blosxom::Header - Set HTTP headers in an object-oriented way

=head1 SYNOPSIS

  use Blosxom::Header;

  my $header = Blosxom::Header->new();
  
  $header->set(
    type          => 'text/html;',
    status        => '304',
    cache_control => 'must-revalidate',
  );
  my $value = $header->get('status');           # 304 Not Modified
  my $bool  = $header->exists('cache_control'); # 1
  my @keys  = $header->keys();                  # ('type', 'status', 'cache_control')

  $header->remove('cache_control');
  @keys = $header->keys(); # ('type', 'status')

  $header->remove_all();
  @keys = $header->keys(); # ()

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item $header = Blosxom::Header->new();

Creates a new Blosxom::Header object.

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


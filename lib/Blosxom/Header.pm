package Blosxom::Header;

use strict;
use warnings;
use Carp;
use HTTP::Status qw(status_message);

our $VERSION = '0.01';

sub new {
    my $self = shift;
    $blosxom::header ||= {};
    return bless $blosxom::header, $self;
}

sub get {
    my $self = shift;
    my $key  = shift;

    return $self->{"-$key"};
}

sub exists {
    my $self = shift;
    my $key  = shift;

    return exists $self->{"-$key"};
}

sub remove {
    my ($self, @keys) = @_;

    for my $key (@keys) {
        delete $self->{"-$key"};
    }

    return;
}

sub keys {
    my $self = shift;
    my @keys = keys %$self;

    for (@keys) { $_ =~ s{^-}{} }

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

        $self->{"-$key"} = $value;
    }

    return;
}

1;

__END__

=head1 NAME

Blosxom::Header - Missing interface to modify HTTP headers

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

=head1 DESCRIPTION

Blosxom, a weblog application, exports a global variable $header
which is a reference to hash. This application passes $header CGI::header()
to generate HTTP headers.

When plugin writers modify HTTP headers, they must write as follows:

  package foo;
  $blosxom::header->{'-status'} = '304 Not Modified';

It's obviously bad practice. Blosxom misses the interface to modify
HTTP headers.  

This module allows you to modify them in an object-oriented way.
If loaded, you might write as follows:

  my $header = Blosxom::Header->new();
  $header->set('status' => '304');

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

Deletes the specified elements from HTTP headers.

=item $header->set(%headers)

Set values of the specified HTTP headers.

=item $header->keys()

Returns a list of all the keys of HTTP headers.

=back

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


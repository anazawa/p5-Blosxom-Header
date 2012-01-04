package Blosxom::Header;

use strict;
use warnings;
use Carp;
use HTTP::Status qw(status_message);

our $VERSION = '0.01004';

sub new {
    my $class   = shift;
    my $headers = {};

    if (!$blosxom::header) {
        carp q{$blosxom::header hasn't been initialized yet.};
        return;
    }

    while (my ($key, $value) = each %$blosxom::header) {
        $key =~ s{^-}{};
        $key = 'Content-Type' if $key eq 'type';
        $headers->{$key} = $value;
    }

    return bless $headers, $class;
}

sub remove {
    my $self = shift;
    my @keys = @_;

    for my $key (@keys) {
        delete $self->{$key};
    }

    return;
}

sub set {
    my $self    = shift;
    my %headers = @_;

    while (my ($key, $value) = each %headers) {
        $value =~ s{\n.*}{}s;
        $self->{$key} = $value;
    }

    return;
}

sub DESTROY {
    my $self    = shift;
    my %headers = ();

    while (my ($key, $value) = each %$self) {
        if ($key eq 'Status' and $value =~ m{^\d\d\d$}) {
            if (my $message = status_message($value)) {
                $value .= q{ } . $message;
            }
            else {
                carp "Unknown status code: " . $value;
            }
        }

        $headers{"-$key"} = $value;
    }

    %$blosxom::header = %headers;

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
    'Content-Type'  => 'text/html;',
    'Status'        => '304',
    'Cache-Control' => 'must-revalidate',
  );
  my $value = $header->{'Status'};               # 304 Not Modified
  my $bool  = exists $header->{'Cache-Control'}; # 1
  $header->remove('Cache-Control', 'Status');

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

=item $header->remove('foo', 'bar')

Deletes the specified elements from HTTP headers.

=item $header->set(%headers)

Set values of the specified HTTP headers.

=back

=head1 DIAGNOSTICS

=over 4

=item $blosxom::header hasn't been initialized yet.

You can't modify HTTP headers until Blosxom initializes $blosxom::header. 

=item Unknown status code

The specified status code doesn't match any status codes defined by RFC2616.

  $header->set('status' => '123') # Unknown status code: 123

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


package Blosxom::Header;
use strict;
use warnings;
use Carp;

our $VERSION = '0.01006';

sub new {
    my $class = shift;

    if (!$blosxom::header) {
        carp q{$blosxom::header hasn't been initialized yet.};
        return;
    }

    return bless {}, $class;
}

sub get {
    my $self    = shift;
    my $key     = _lc(shift);
    my $headers = $blosxom::header;

    my @values;
    while (my ($k, $v) = each %$headers) {
        push @values, $v if lc $k eq $key;
    }

    return wantarray ? @values : $values[0];
}

sub remove {
    my $self    = shift;
    my $key     = _lc(shift);
    my $headers = $blosxom::header;

    my %new_headers;
    while (my ($k, $v) = each %$headers) {
        $new_headers{$k} = $v unless lc $k eq $key;
    }

    %$headers = %new_headers;

    return;
}

sub set {
    my $self    = shift;
    my $key     = shift;
    my $value   = shift;
    my $headers = $blosxom::header;

    $key = lc $key eq 'content-type' ? '-type' : "-$key";

    my ($set, %new_headers);
    while (my ($k, $v) = each %$headers) {
        if (lc $key eq lc $v) {
            next if $set;
            $v = $value;
            $set++;
        }
        $new_headers{$k} = $v;
    }

    $new_headers{$key} = $value unless $set;
    %$headers = %new_headers;

    return;
}

sub exists {
    my $self    = shift;
    my $key     = _lc(shift);
    my $headers = $blosxom::header;

    my $exists;
    while (my ($k, $v) = each %$headers) {
        $exists = 1 if lc $k eq $key;
    }

    return $exists;
}

sub push {
    my $self  = shift;
    my $key   = shift;
    #my $value = shift;
    my $value = join ', ', $self->get($key), shift;

    $self->set($key => $value);

    return;
}

sub _lc {
    my $key = lc shift;
    return $key eq 'content-type' ? '-type' : "-$key";
}

1;

__END__

=head1 NAME

Blosxom::Header - Missing interface to modify HTTP headers

=head1 SYNOPSIS

  use Blosxom::Header;

  # OO interface
  my $header = Blosxom::Header->new('Content-Type' => 'text/html');
  $header->set(
    'Status'        => '304',
    'Cache-Control' => 'must-revalidate',
  );
  $header->remove('Cache-Control', 'Status');

  # As a reference to hash
  $header->{'Content-Type'} = 'text/plain';
  my $value = $header->{'Content-Type'};        # text/plain
  my $bool  = exists $header->{'Content-Type'}; # 1
  delete $header->{'Content-Type'};

=head1 DESCRIPTION

Blosxom, a weblog application, exports a global variable $header
which is a reference to hash. This application passes $header CGI::header()
to generate HTTP headers.

When plugin writers modify HTTP headers, they must write as follows:

  package foo;
  $blosxom::header->{'-Status'} = '304 Not Modified';

It's obviously bad practice. Blosxom misses the interface to modify
them.  

This module allows you to modify them in an object-oriented way.
If loaded, you might write as follows:

  my $header = Blosxom::Header->new();
  $header->{'Status'} = '304';

=head1 METHODS

=over 4

=item $header = Blosxom::Header->new();

=item $header = Blosxom::Header->new(%headers);

Creates a new Blosxom::Header object.
Returns a reference to hash which represents HTTP header fields:

  $header->{'Content-Type'} = 'text/plain';
  my $value = $header->{'Content-Type'};        # text/plain
  my $bool  = exists $header->{'Content-Type'}; # 1
  delete $header->{'Content-Type'};

If %headers was defined,

  my $header = Blosxom::Header->new(
    'Content-Type'  => 'text/html',
    'Cache-Control' => 'must-revalidate',
  );

would override existing headers.

=item $header->remove('foo', 'bar')

Deletes the specified elements from HTTP headers.

Following code:

  $header->remove('Content-Type');

equals to

  delete $header->{'Content-Type'};

semantically.

=item $header->set(%headers)

Sets values of the specified HTTP headers.

Following code:

  $header->set('Content-Type' => 'text/html');

equals to

  $header->{'Content-Type'} = 'text/html';

semantically.

=item $header->DESTROY()

Will be called automatically when $header goes away.
And so you don't have to call it explicitly.

If the Status header is specified,

  $header->{'Status'} = '304';

'304' will be autocompleted as '304 Not Modified'.

=back

=head1 DIAGNOSTICS

=over 4

=item $blosxom::header hasn't been initialized yet.

You can't modify HTTP headers until Blosxom initializes $blosxom::header. 

=item Unknown status code

The specified status code doesn't match any status codes defined
by RFC2616.

=back

=head1 DEPENDENCIES

L<HTTP::Status>, Blosxom 2.1.2

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 Ryo Anazawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


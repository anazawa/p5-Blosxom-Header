package Blosxom::Header;
use strict;
use warnings;

our $VERSION = '0.01010';

sub new {
    my $class   = shift;
    my $headers = shift;

    bless { headers => $headers }, $class;
}

sub get {
    my $self    = shift;
    my $key     = lc shift;
    my $headers = $self->{headers};

    my @keys   = grep {"-$key" eq lc $_} sort keys %$headers;
    my @values = @{$headers}{@keys};

    wantarray ? @values : $values[0];
}

sub set {
    my $self    = shift;
    my $key     = shift;
    my $value   = shift;
    my $headers = $self->{headers};

    my $set;
    for (sort keys %$headers) {
        if (lc "-$key" eq lc $_) {
            $headers->{$_} = $value;
            $set++;
            last;
        }  
    } 

    $headers->{"-$key"} = $value unless $set;

    return;
}

sub exists {
    my $self = shift;
    my $key  = lc shift;

    for (keys %{$self->{headers}}) {
        return 1 if lc $_ eq "-$key"; # any
    } 

    return;
}

sub remove {
    my $self    = shift;
    my $key     = lc shift;
    my $headers = $self->{headers};

    my @keys = grep {lc $_ eq "-$key"} keys %$headers;
    delete @{$headers}{@keys}; # slice

    return;
}

# 'push' methods
for my $field (qw(cookie p3p)) {
    my $slot = __PACKAGE__ . "::push_$field";

    no strict 'refs';

    *$slot = sub {
        my $self  = shift;
        my $value = shift;

        if (my $old_value = $self->get($field)) {
            if (ref $old_value eq 'ARRAY') {
                push @$old_value, $value;
            }
            else {
                $self->set($field => [$old_value, $value]);
            }
        }
        else {
            $self->set($field => $value);
        }

        return;
    };
}

# Accessors
for my $field (qw(type nph expires cookie charset attachment p3p)) {
    my $slot = __PACKAGE__ . "::$field";

    no strict 'refs';

    *$slot = sub {
        my $self  = shift;
        my $value = shift;

        if ($value) {
            $self->set($field => $value);
        }
        else {
            my @values = $self->get($field);
            wantarray ? @values : $values[0];
        }
    };
}

1;

__END__

=head1 NAME

Blosxom::Header - Missing interface to modify HTTP headers

=head1 SYNOPSIS

  use Blosxom::Header;

  my $headers = { -type => 'text/html' };

  my $h = Blosxom::Header->new($headers);
  my $value = $h->get($key);
  my $bool = $h->exists($key);

  $h->set($key, $value); # overwrites existent header
  $h->remove($key);

  $h->{headers}; # same reference as $headers

=head1 DESCRIPTION

Blosxom, a weblog application, exports a global variable $header
which is a reference to hash. This application passes $header CGI::header()
to generate HTTP headers.

When plugin developers modify HTTP headers, they must write as follows:

  package foo;
  $blosxom::header->{'-type'} = 'text/plain';

It's obviously bad practice. Blosxom misses the interface to modify
them.  

This module allows you to modify them in an object-oriented way.
If loaded, you might write as follows:

  my $h = Blosxom::Header->new($blosxom::header);
  $h->type('text/plain');

=head2 METHODS

=over 4

=item $h = Blosxom::Header->new($headers);

Creates a new Blosxom::Header object.
The object holds a reference to the original given $headers argument.

=item $h->get('foo')

Returns a value of the specified HTTP header.

=item $h->exists('foo')

Returns a Boolean value telling whether the specified HTTP header exists.

=item $h->set('foo' => 'bar')

Sets a value of the specified HTTP header.

=item $h->remove('foo')

Deletes the specified element from HTTP headers.

=back

=head3 ACCESSORS

=over 4

=item $h->type()

Gets or sets the Content-Type header.

  $h->type('text/plain')

=item $h->nph()

Gets or sets a Boolean value telling whether to issue the correct
headers to work with a NPH (no-parse-header) script.

  $h->nph(1)

=item $h->expires()

Gets or sets the Expires header.
You can specify an absolute or relative expiration interval.
The following forms are all valid for this field.

  $h->expires('+30s') # 30 seconds from now
  $h->expires('+10m') # ten minutes from now
  $h->expires('+1h')  # one hour from now
  $h->expires('-1d')  # yesterday
  $h->expires('now')  # immediately
  $h->expires('+3M')  # in three months
  $h->expires('+10y') # in ten years time

  # at the indicated time & date
  $h->expires('Thursday, 25-Apr-1999 00:40:33 GMT')

=item $h->cookie()

Gets or sets the Set-Cookie header.
The parameter can be an arrayref or a string.

=item $h->push_cookie()

Adds the Set-Cookie header.

=item $h->charset()

Gets or sets the character set sent to the browser.
If not provided, defaults to ISO-8859-1.

  $h->charset('utf-8')

=item $h->attachment()

Can be used to turn the page into an attachment.
The value of the argument is suggested name for the saved file.

  $h->attachment('foo.png')

=item $h->p3p()

Gets or sets the P3P tags.
The parameter can be arrayref or a space-delimited string.

  $h->p3p([qw(CAO DSP LAW CURa)])
  $h->p3p('CAO DSP LAW CURa')

In either case, the outgoing header will be formatted as:

  P3P: policyref="/w3c/p3p.xml" cp="CAO DSP LAW CURa"

=item $h->push_p3p()

=back

=head1 EXAMPLES

The following code is a Blosxom plugin to enable conditional GET and HEAD using
C<If-None-Match> and C<If-Modified-Since> headers.
Refer to L<Plack::Middleware::ConditionalGET>.

plugins/conditional_get:

  package conditional_get;
  use strict;
  use warnings;
  use Blosxom::Header;

  sub start { !$blosxom::static_entries }

  sub last {
      return unless $ENV{REQUEST_METHOD} =~ /^(GET|HEAD)$/;

      my $h = Blosxom::Header->new($blosxom::header);
      if (etag_matches($h) or not_modified_since($h)) {
          $h->set('Status' => '304 Not Modified');
          $h->remove($_)
              for qw(Content-Type Content-Length Content-Disposition);

          # Truncate output
          $blosxom::output = q{};
      }

      return;
  }

  sub etag_matches {
      my $h = shift;
      return unless $h->exists('ETag');
      $h->get('ETag') eq _value($ENV{HTTP_IF_NONE_MATCH});
  }

  sub not_modified_since {
      my $h = shift;
      return unless $h->exists('Last-Modified');
      $h->get('Last-Modified') eq _value($ENV{HTTP_IF_MODIFIED_SINCE});
  }

  sub _value {
      my $str = shift;
      $str =~ s{;.*$}{};
      $str;
  }
  
  1;

=head1 DEPENDENCIES

L<Blosxom 2.1.2|http://blosxom.sourceforge.net/>

=head1 SEE ALSO

The interface of this module is inspired by L<Plack::Util>::headers.

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 Ryo Anazawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

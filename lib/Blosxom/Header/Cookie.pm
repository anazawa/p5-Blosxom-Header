package Blosxom::Header::Cookie;
use strict;
use warnings;
use CGI qw(cookie);

our $VERSION = '0.01001';

sub new {
    my $class   = shift;
    my $headers = shift;

    bless { headers => $headers }, $class;
}

sub get {
    my $self    = shift;
    my $key     = shift;
    my $headers = $self->{headers};

    return unless exists $headers->{-cookie};

    my @val;
    my $cookies = $headers->{-cookie};
    if (ref $cookies eq 'ARRAY') {
        for my $cookie (@$cookies) {
            push @val, $cookie->value
                if $cookie->name() eq $key;
        }
    }
    else {
        push @val, $cookies->value();
    }

    return wantarray ? @val : $val[0];
}

sub push {
    my $self    = shift;
    my $cookie  = cookie(@_);
    my $headers = $self->{headers};

    if (exists $headers->{-cookie}) {
        my $cookies = $headers->{-cookie};
        if (ref $cookies eq 'ARRAY') {
            push @$cookies, $cookie;
        }
        else {
            $headers->{-cookie} = [$cookies, $cookie];
        }
    }
    else {
        $headers->{-cookie} = $cookie;
    }

    return;
}

sub remove {
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

When plugin writers modify HTTP headers, they must write as follows:

  package foo;
  $blosxom::header->{'-type'} = 'text/plain';

It's obviously bad practice. Blosxom misses the interface to modify
them.  

This module allows you to modify them in an object-oriented way.
If loaded, you might write as follows:

  my $h = Blosxom::Header->new($blosxom::header);
  $h->set('Content-Type' => 'text/plain');

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
      if (_etag_matches($h) or _not_modified_since($h)) {
          $h->set('Status' => '304 Not Modified');
          $h->remove($_)
              for qw(Content-Type Content-Length Content-Disposition);

          # Truncate output
          $blosxom::output = q{};
      }

      return;
  }

  sub _etag_matches {
      my $h = shift;
      return unless $h->exists('ETag');
      $h->get('ETag') eq _value($ENV{HTTP_IF_NONE_MATCH});
  }

  sub _not_modified_since {
      my $h = shift;
      return unless $h->exists('Last-Modified');
      $h->exists('Last-Modified') eq _value($ENV{HTTP_IF_MODIFIED_SINCE});
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

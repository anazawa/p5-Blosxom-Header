package Blosxom::Header;
use 5.008_009;
use strict;
use warnings;
use base qw/Exporter/;
use constant USELESS => 'Useless use of %s with no values';
use Blosxom::Header::Proxy;
use Carp qw/carp/;
use HTTP::Status qw/status_message/;

our $VERSION = '0.05004';

our @EXPORT_OK = qw(
    $Header       header_get    header_set
    header_exists header_delete header_push
);

our $Header;

sub import {
    my ( $class, $export ) = @_;
    $Header = $class->instance if $export and $export eq '$Header';
    $class->export_to_level( 1, @_ );
}


# Functions

sub header_get    { __PACKAGE__->instance->get( @_ )    }
sub header_set    { __PACKAGE__->instance->set( @_ )    }
sub header_exists { __PACKAGE__->instance->exists( @_ ) }
sub header_delete { __PACKAGE__->instance->delete( @_ ) }
sub header_push   { __PACKAGE__->instance->_push( @_ )  }


# Class methods

my $instance;

sub instance {
    my $class = shift;
    return $class if ref $class;
    return $instance if defined $instance;
    $instance = $class->_new_instance;
}

sub _new_instance {
    my $class = shift;
    tie my %proxy => 'Blosxom::Header::Proxy';
    bless \%proxy => $class;
}

sub has_instance { $instance }


# Instance methods

sub is_initialized { shift->_proxy->is_initialized }

sub _proxy { tied %{ $_[0] } }

sub get {
    my ( $self, @fields ) = @_;
    return _carp( USELESS, 'get()' ) unless @fields;
    @{ $self }{ @fields };
}

sub set {
    my ( $self, %fields ) = @_;
    return _carp( USELESS, 'set()' ) unless %fields;
    @{ $self }{ keys %fields } = values %fields;
    return;
}

sub delete {
    my ( $self, @fields ) = @_;
    return _carp( USELESS, 'delete()' ) unless @fields;
    delete @{ $self }{ @fields };
}

sub exists { exists $_[0]->{ $_[1] } }
sub clear  { %{ $_[0] } = ()         }

sub push_cookie { shift->_push( Set_Cookie => @_ ) }
sub push_p3p    { shift->_push( P3P        => @_ ) }

sub _push {
    my ( $self, $field, @values ) = @_;

    return _carp( USELESS, '_push()' ) unless @values;

    if ( my $value = $self->{ $field } ) {
        return push @{ $value }, @values if ref $value eq 'ARRAY';
        unshift @values, $value;
    }

    $self->{ $field } = @values > 1 ? \@values : $values[0];

    scalar @values;
}

sub expires {
    my $self = shift;
    return $self->{Expires} = shift if @_;
    $self->{Expires};
}

sub target {
    my $self = shift;
    return $self->{Window_Target} = shift if @_;
    $self->{Window_Target};
}

sub attachment { shift->_proxy->attachment( @_ ) }
sub nph        { shift->_proxy->nph( @_ )        }

sub cookie {
    my $self = shift;

    if ( @_ > 1 ) {
        $self->{Set_Cookie} = [ @_ ];
        return wantarray ? @_ : $_[0];
    }
    elsif ( @_ ) {
        return $self->{Set_Cookie} = shift;
    }

    if ( my $cookies = $self->{Set_Cookie} ) {
        return $cookies unless ref $cookies eq 'ARRAY';
        return wantarray ? @{ $cookies } : $cookies->[0];
    }

    return;
}

sub p3p {
    my $self = shift;

    if ( @_ > 1 ) {
        $self->{P3P} = [ @_ ];
        return wantarray ? @_ : $_[0];
    }
    elsif ( @_ ) {
        my @tags = split / /, shift;
        $self->{P3P} = @tags > 1 ? \@tags : $tags[0];
        return wantarray ? @tags : $tags[0];
    }

    if ( my $tags = $self->{P3P} ) {
        my @tags = ref $tags eq 'ARRAY' ? @{ $tags } : ( $tags );
        @tags = map { split / / } @tags;
        return wantarray ? @tags : $tags[0];
    }

    return;
}

sub type {
    my $self = shift;

    $self->{Content_Type} = shift if @_;

    if ( my $content_type = $self->{Content_Type} ) {
        my ( $type, $rest ) = split /;\s*/, $content_type, 2;
        return q{} unless defined $type;
        $type =~ s/\s+//g;
        $type = lc $type;
        return wantarray ? ( $type, $rest ) : $type;
    }

    return;
}

sub charset {
    my $self = shift;

    if ( my $content_type = $self->{Content_Type} ) {
        my ( $charset ) = ( $content_type =~ /charset="?([^;"]+)"?/ );
        return uc $charset if $charset;
    }

    return;
}

sub status {
    my $self = shift;

    if ( @_ ) {
        my $code = shift;

        if ( my $message = status_message( $code ) ) {
            $self->{Status} = "$code $message";
        }
        else {
            carp( qq{Unknown status code "$code" passed to status()} );
            return;
        }

        return $code;
    }
    elsif ( my $status = $self->{Status} ) {
        return substr( $status, 0, 3 );
    }

    return;
}

sub field_names { keys %{ $_[0] } }


# Internal functions

sub _carp {
    my ( $format, @args ) = @_;
    carp( sprintf $format, @args );
}

1;

__END__

=head1 NAME

Blosxom::Header - Missing interface to modify HTTP headers

=head1 SYNOPSIS

  # Object-oriented interface

  use Blosxom::Header;

  my $Header = Blosxom::Header->instance;

  # or

  use Blosxom::Header qw/$Header/;

  $Header->set(
      Status        => '304 Not Modified',
      Last_Modified => 'Wed, 23 Sep 2009 13:36:33 GMT',
  );

  my $status = $Header->get( 'Status' );
  my @deleted = $Header->delete( qw/Content-Disposition Content-Length/ );

  # Procedural interface

  use Blosxom::Header qw( header_set header_get header_delete );

  header_set(
      Status        => '304 Not Modified',
      Last_Modified => 'Wed, 23 Sep 2009 13:36:33 GMT',
  );

  my $status = header_get( 'Status' );
  my @deleted = header_delete( qw/Content-Disposition Content-Length/ );

=head1 DESCRIPTION

Blosxom, an weblog application, globalizes C<$header> which is a reference to
a hash. This application passes C<$header> to C<CGI::header()> to generate HTTP
headers.

  package blosxom;
  use strict;
  use warnings;
  use CGI qw/header/;

  our $header = { -type => 'text/html' };

  # Loads plugins

  print header( $header );

Plugins may modify C<$header> directly because the variable is global.
On the other hand, C<header()> doesn't care whether keys of C<$header> are
lowercased nor start with a dash.
There is no agreement with how to normalize keys of C<$header>.

=head2 HOW THIS MODULE NORMALIZES FIELD NAMES

To specify field names consistently, we need to normalize them.
If you follow one of normalization rules, you can modify C<$header>
consistently. This module normalizes field names as follows.

Remember how Blosxom initializes C<$header>:

  $header = { -type => 'text/html' };

A key C<-type> is starting with a dash and lowercased, and so this module
follows the same rules:

  'Status'  # not normalized
  'status'  # not normalized
  '-status' # normalized

How about C<Content-Length>? It contains a dash.
To avoid quoting when specifying hash keys, this module transliterates dashes
into underscores in field names:

  'Content-Length'  # not normalized
  '-content-length' # not normalized
  '-content_length' # normalized

If you follow the above normalization rule, you can modify C<$header> directly.
In other words, this module is compatible with the way modifying C<$header>
directly when you follow the above rule.
L<Blosxom::Header::Fast> explains the details.

=head2 VARIABLE

The following variable is exported on demand.

=over 4

=item $Header

The same reference as C<< Blosxom::Header->instance >> returns.

  use Blosxom::Header qw/$Header/;

In this case, this module creates the instance when loaded.
Otherwise doesn't.

=back

=head2 FUNCTIONS

The following functions are exported on demand.

=over 4

=item @values = header_get( @fields )

A synonym for C<< Blosxom::Header->instance->get() >>.

=item header_set( $field => $value )

=item header_set( $f1 => $v2, $f2 => $v2, ... )

A synonym for C<< Blosxom::Header->instance->set() >>.

=item $bool = header_exists( $field )

A synonym for C<< Blosxom::Header->instance->exists() >>.

=item @deleted = header_delete( @fields )

A synonym for C<< Blosxom::Header->instance->delete() >>.

=item header_push( Set_Cookie => @cookies )

A synonym for C<< Blosxom::Header->instance->push_cookie() >>.

=item header_push( P3P => @tags )

A synonym for C<< Blosxom::Header->instance->push_p3p() >>.

=back

=head2 CLASS METHODS

=over 4

=item $header = Blosxom::Header->instance

Returns a current Blosxom::Header object instance or create a new one.
This class can have only one instance in any system.

=item $header = Blosxom::Header->has_instance

Returns a reference to any existing instance or C<undef> if none is defined.

=back

=head2 INSTANCE METHODS

=over 4

=item $bool = $header->is_initialized

Returns a Boolean value telling whether C<$blosxom::header> is initialized or
not. Blosxom initializes the variable just before C<blosxom::generate()> is
called. If C<$bool> was false, the following methods would throw exceptions.

Internally, this method is a shortcut for

  $bool = ref $blosxom::header eq 'HASH';

=item $value = $header->get( $field )

=item @values = $header->get( @fields )

Returns the value of one or more header fields.
Accepts a list of field names.
C<$field> isn't case-sensitive.
You can use underscores as a replacement for dashes.
The following forms are semantically equivalent:

  $header->get( 'Last-Modified'  );
  $header->get( 'Last_modified'  );
  $header->get( '-last_modified' );

=item $header->set( $field => $value )

=item $header->set( $f1 => $v1, $f2 => $v2, ... )

Sets the value of one or more header fields.
Accepts a list of named arguments.

The $value argument must be a plain string, except for when the Set-Cookie
or P3P header is specified.
In exceptional cases, $value may be a reference to an array.

  $header->set(
      Set_Cookie => [ $cookie1, $cookie2 ],
      P3P        => [ 'CAO', 'DSP', 'LAW', 'CURa' ],
  );

=item $bool = $header->exists( $field )

Returns a Boolean value telling whether the specified HTTP header exists.
Accepts a field name.

=item @deleted = $header->delete( @fields )

Deletes the specified fields from HTTP headers.
Accepts a list of field names.
Returns values of deleted fields.

=item $header->push_cookie( @cookies )

Pushes the Set-Cookie headers onto HTTP headers.
Accepts a list of cookies.
Returns the number of the elements following the completed
push_cookie().  

  # get values of Set-Cookie headers
  my @cookies = $header->cookie; # ( 'foo', 'bar' )

  # add Set-Cookie header
  $header->push_cookie( 'baz' );

  @cookies = $header->cookie; # ( 'foo', 'bar', 'baz' )

=item $header->push_p3p( @p3p )

Adds P3P tags to the P3P header.
Accepts a list of P3P tags.

  # get P3P tags
  my @tags = $header->p3p; # ( 'CAO', 'DSP', 'LAW' )

  # add P3P tags
  $header->push_p3p( 'CURa' );

  @tags = $header->p3p; # ( 'CAO', 'DSP', 'LAW', 'CURa' )

=item $header->clear

This will remove all header fields.

Internally, this method is a shortcut for

  %{ $blosxom::header } = ( -type => q{} );

If C<-type> element didn't exist, C<< CGI::header() >> would output the default
Content-Type header.

=item @fields = $header->field_names

Returns the list of distinct names for the fields present in the header.
In scalar context return the number of distinct field names.

=back

=head2 CONVENIENCE METHODS

The following methods were named after parameters recognized by
C<CGI::header()>.
They can both be used to read and to set the value of an attribute.
The value is set if you pass an argument to the method.
If the given attribute wasn't defined then C<undef> is returned.

=over 4

=item $header->attachment

Can be used to turn the page into an attachment.
Represents suggested name for the saved file.

  $header->attachment( 'genome.jpg' );
  my $attachment = $header->attachment; # genome.jpg

  my $cd = $header->get( 'Content-Disposition' );
  # => 'attachment; filename="genome.jpg"'

=item $header->charset

Returns the upper-cased character set specified in the Content-Type header.

  $charset = $header->charset; # UTF-8 (Readonly)

=item $header->cookie

Represents the Set-Cookie headers.
The parameter can be an array.

  $header->cookie( 'foo', 'bar' );
  my @cookies = $header->cookie; # ( 'foo', 'bar' )

=item $header->expires

The Expires header gives the date and time after which the entity should be
considered stale.
You can specify an absolute or relative expiration interval.
The following forms are all valid for this field:

  $header->expires( '+30s' ); # 30 seconds from now
  $header->expires( '+10m' ); # ten minutes from now
  $header->expires( '+1h'  ); # one hour from now
  $header->expires( '-1d'  ); # yesterday
  $header->expires( 'now'  ); # immediately
  $header->expires( '+3M'  ); # in three months
  $header->expires( '+10y' ); # in ten years time

  # at the indicated time & date
  $header->expires( 'Thu, 25 Apr 1999 00:40:33 GMT' );

=item $header->nph

If set to a true value,
will issue the correct headers to work with
a NPH (no-parse-header) script:

  $header->nph( 1 );

=item $header->p3p

Represents the P3P header.
The parameter can be an array or a space-delimited string.

  $header->p3p( qw/CAO DSP LAW CURa/ );
  $header->p3p( 'CAO DSP LAW CURa' );

  my @tags = $header->p3p; # ( 'CAO', 'DSP', 'LAW', 'CURa' )

In either case, the outgoing header will be formatted as:

  P3P: policyref="/w3c/p3p.xml" CP="CAO DSP LAW CURa"

=item $header->status

Represents HTTP status code.

  $header->status( 304 );
  my $code = $header->status; # 304

  my $status = $header->get( 'Status' ); # 304 Not Modified
  $header->set( Status => '304 Not Modified' );

=item $header->target

Represents the Window-Target header.

  $header->target( 'ResultsWindow' );
  my $target = $header->target; # ResultsWindow

cf.

  $header->set( Window_Target => 'ResultsWindow' );
  $target = $header->get( 'Window-Target' ); # ResultsWindow

=item $header->type

The Content-Type header indicates the media type of the message content.

  $header->type( 'text/plain; charset=utf-8' );

  $header->set( Content_Type => 'text/plain; charset=utf-8' );

The value returned will be converted to lower case, and potential parameters
will be chopped off and returned as a separate value if in an array context.

  my $type = $header->type; # 'text/html'
  my @ct   = $header->type; # ( 'text/html', 'charset=ISO-8859-1' )

  my $ct = $header->get( 'Content-Type' ); # 'text/html; charset=ISO-8859-1'

If there is no such header field, then the empty string is returned.
This makes it safe to do the following:

  if ( $header->type eq 'text/html' ) {
      ...
  }

=back

=head1 DIAGNOSTICS

=over 4

=item $blosxom::header hasn't been initialized yet

You attempted to modify C<$blosxom::header>
before the variable was initialized.
See C<< $header->is_initialized >>.

=item Useless use of %s with no values

You used the C<push_cookie()> or C<push_p3p()> method with no argument
apart from the array,
like C<< $header->push_cookie() >> or C<< $header->push_p3p() >>.

=item Unknown status code "%d%d%d" passed to status()

The given status code is unknown to L<HTTP::Status>.

=back

=head1 DEPENDENCIES

L<Blosxom 2.0.0|http://blosxom.sourceforge.net/> or higher.

=head1 SEE ALSO

L<Blosxom::Header::Proxy>,
L<CGI>,
L<Class::Singleton>

=head1 ACKNOWLEDGEMENT

Blosxom was written by Rael Dornfest.
L<The Blosxom Development Team|http://sourceforge.net/projects/blosxom/>
succeeded the maintenance.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to ANAZAWA (anazawa@cpan.org).
Patches are welcome.

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011-2012 Ryo Anazawa. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut


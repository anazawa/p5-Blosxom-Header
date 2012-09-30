package Blosxom::Header::Simple;
use strict;
use warnings;
use Exporter 'import';
use CGI::Util qw//;
use Carp qw/carp croak/;
use Scalar::Util qw/refaddr/;
use List::Util qw/first/;

our $VERSION = '0.01';

our @EXPORT_OK = qw(
    header_get    header_set   header_exists
    header_delete header_clear
);

my %get = (
    -content_disposition => sub {
        my ( $header, $norm ) = @_;
        my $filename = $header->{-attachment};
        $filename ? qq{attachment; filename="$filename"} : $header->{ $norm };
    },
    -content_type => sub {
        my $header  = shift;
        my $type    = $header->{-type};
        my $charset = $header->{-charset};

        if ( defined $type and $type eq q{} ) {
            undef $charset;
            undef $type;
        }
        else {
            $type ||= 'text/html';

            if ( $type =~ /\bcharset\b/ ) {
                undef $charset;
            }
            elsif ( !defined $charset ) {
                $charset = 'ISO-8859-1';
            }
        }

        $charset ? "$type; charset=$charset" : $type;
    },
    -date => sub {
        my ( $header, $norm ) = @_;
        my $is_fixed = first { $header->{$_} } qw(-nph -expires -cookie);
        $is_fixed ? CGI::Util::expires() : $header->{ $norm };
    },
    -expires => sub {
        my $expires = shift->{-expires};
        $expires && CGI::Util::expires( $expires )
    },
    -p3p => sub {
        my $tags = shift->{-p3p};
        $tags = join ' ', @{ $tags } if ref $tags eq 'ARRAY';
        $tags && qq{policyref="/w3c/p3p.xml", CP="$tags"};
    },
    -set_cookie    => sub { shift->{-cookie} },
    -window_target => sub { shift->{-target} },
);

sub header_get {
    my $header = shift;
    my $norm = _normalize( shift ) || return;
    my $get = $get{ $norm };
    $get ? $get->( $header, $norm ) : $header->{ $norm };
}

my %set = (
    -content_disposition => sub {
        my ( $header, $norm, $value ) = @_;
        delete $header->{-attachment} if $value;
        $header->{ $norm } = $value;
    },
    -content_type => sub {
        my ( $header, $norm, $value ) = @_;
        @{ $header }{qw/-type -charset/} = ( $value, q{} );
    },
    -date => sub {
        my ( $header, $norm, $value ) = @_;
        return if first { $header->{$_} } qw(-nph -expires -cookie);
        $header->{ $norm } = $value;
    },
    #-expires => sub {
    #    carp "Can't assign to '-expires' directly, use expires() instead";
    #},
    #-p3p => sub {
    #    carp "Can't assign to '-p3p' directly, use p3p_tags() instead";
    #},
    -set_cookie => sub {
        my ( $header, $norm, $value ) = @_;
        delete $header->{-date} if $value;
        $header->{-cookie} = $value;
    },
    -window_target => sub {
        my ( $header, $norm, $value ) = @_;
        $header->{-target} = $value;
    },
);

sub header_set {
    my $header = shift;
    my $norm   = _normalize( shift ) || return;
    my $value  = shift;

    if ( my $set = $set{$norm} ) {
        $set->( $header, $norm, $value );
    }
    else {
        $header->{ $norm } = $value;
    }

    return;
}

my %exists = (
    -content_type => sub {
        my $header = shift;
        !defined $header->{-type} || $header->{-type} ne q{};
    },
    -content_disposition => sub {
        my ( $header, $norm ) = @_;
        exists $header->{ $norm } || $header->{-attachment};
    },
    -date => sub {
        my ( $header, $norm ) = @_;
        exists $header->{ $norm }
            || first { $header->{$_} } qw(-nph -expires -cookie );
    },
    -set_cookie    => sub { exists shift->{-cookie} },
    -window_target => sub { exists shift->{-target} },
);

sub header_exists {
    my $header = shift;
    my $norm = _normalize( shift ) || return;
    my $exists = $exists{ $norm };
    $exists ? $exists->( $header, $norm ) : exists $header->{ $norm };
}

my %delete = (
    -content_disposition => sub { delete $_[0]->{-attachment} },
    -content_type => sub {
        my $header = shift;
        delete $header->{-charset};
        $header->{-type} = q{};
    },
    -set_cookie    => sub { delete @{ $_[0] }{qw/-cookie -cookies/} },
    -window_target => sub { delete $_[0]->{-target} },
);

sub header_delete {
    my ( $header, $field ) = @_;
    my $norm = _normalize( $field ) || return;
    my $value = defined wantarray && header_get( $header, $field );
    do { $delete{$norm} || sub {} }->( $header );
    delete $header->{ $norm };
    $value;
}

my %is_ignored = map { $_ => 1 }
    qw( attachment charset cookie cookies nph target type );

sub _normalize {
    my $norm = lc shift;
    $norm =~ tr/-/_/;
    $is_ignored{ $norm } ? undef : "-$norm";
}

sub header_clear {
    my $header = shift;
    %{ $header } = ( -type => q{} );
    return;
}

1;

__END__

=head1 NAME

CGI::Header - Emulates CGI::header()

=head1 SYNOPSIS

  my $header = CGI::Header->new(
      -attachment => 'foo.gif',
      -charset    => 'utf-7',
      -cookie     => $cookie, # CGI::Cookie object
      -expires    => '+3d',
      -nph        => 1,
      -p3p        => [qw/CAO DSP LAW CURa/],
      -target     => 'ResultsWindow',
      -type       => 'image/gif',
  );

  $header->set( 'Content-Length' => 3002 );
  my $value = $header->get( 'Status' );
  my $bool = $header->exists( 'ETag' );
  $header->delete( 'Content-Disposition' );

  $header->attachment( 'genome.jpg' );
  $header->expires( '+3M' );
  $header->nph( 1 );
  $header->p3p_tags(qw/CAO DSP LAW CURa/);

=head1 DESCRIPTION

Accepts the same arguments as CGI::header() does.
Generates the same HTTP response headers as the subroutine does.

=head2 METHODS

=over 4

=item $header = CGI::Header->new( -type => 'text/plain', ... )

Construct a new CGI::Header object.
You might pass some initial attribute-value pairs as parameters to
the constructor:

  my $header = CGI::Header->new(
      -attachment => 'genome.jpg',
      -charset    => 'utf-8',
      -cookie     => 'ID=123456; path=/',
      -expires    => '+3M',
      -nph        => 1,
      -p3p        => [qw/CAO DSP LAW CURa/],
      -target     => 'ResultsWindow',
      -type       => 'text/plain',
  );

=item $value = $eader->get( $field )

=item $header->set( $field => $value )

=item $bool = $header->exists( $field )

Returns a Boolean value telling whether the specified field exists.

  if ( $header->exists('ETag') ) {
      ...
  }

=item $value = $header->delete( $field )

Deletes the specified field.

  $header->delete( 'Content-Disposition' );
  my $value = $header->delete( 'Content-Disposition' ); # inline

=item @fields = $header->field_names

Returns the list of field names present in the header.

  my @fields = $header->field_names;
  # => ( 'Set-Cookie', 'Content-length', 'Content-Type' )

=item $header->each( \&callback )

Apply a subroutine to each header field in turn.
The callback routine is called with two parameters;
the name of the field and a value.
Any return values of the callback routine are ignored.

  my @lines;

  $self->each(sub {
      my ( $field, $value ) = @_;
      push @lines, "$field: $value";
  });

=item @headers = $header->flatten

Returns pairs of fields and values.

  my @headers = $header->flatten;
  # => ( 'Status', '304 Nod Modified', 'Content-Type', 'text/plain' )

=item $header->clear

This will remove all header fields.

=item $bool = $header->is_empty

Returns true if the header contains no key-value pairs.

  $header->clear;

  if ( $header->is_empty ) { # true
      ...
  }

=item $clone = $header->clone

Returns a copy of this CGI::Header object.

=item $header->as_string

=item $header->as_string( $eol )

Returns the header fields as a formatted MIME header.
The optional C<$eol> parameter specifies the line ending sequence to use.
The default is C<\n>.

=item $header->attachment( $filename )

A shortcut for

  $header->set(
      'Content-Disposition' => qq{attachment; filename="$filename"}
  );

=item $header->p3p_tags( $tags )

A shortcut for

  $header->set(
      'P3P' => qq{policyref="/w3c/p3p.xml", CP="$tags"}
  ); 

=item $header->expires

=item $header->header

=back

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistibute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

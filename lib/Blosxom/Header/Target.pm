package Blosxom::Header::Target;
use strict;
use warnings;
use overload '%{}' => 'as_hashref', 'bool' => 'boolify', 'fallback' => 1;
use Blosxom::Header::Adapter;
use Carp qw/carp croak/;
use HTTP::Date ();
use Scalar::Util qw/refaddr/;

my %header_of;
my %adapter_of;
my %iterator_of; # deprecated

sub new {
    my $class  = shift;
    my $header = shift;
    my $self   = bless \do { my $anon_scalar }, $class;
    my $this   = refaddr( $self );

    tie my %header => 'Blosxom::Header::Adapter' => $header;
    $header_of{ $this } = \%header;
    $adapter_of{ $this } = tied %header;
    $iterator_of{ $this } = {}; # deprecated

    $self;
}

sub DESTROY {
    my $self = shift;
    my $this = refaddr( $self );
    delete $header_of{ $this };
    delete $adapter_of{ $this };
    delete $iterator_of{ $this };
}

sub as_hashref {
    my $self = shift;
    $header_of{ refaddr($self) };
}

sub boolify { 1 }

sub get {
    my ( $self, @fields ) = @_;
    @{ $self }{ @fields };
}

sub set {
    my ( $self, %header ) = @_;
    @{ $self }{ keys %header } = values %header; # merge!
    return;
}

sub delete {
    my ( $self, @fields ) = @_;
    delete @{ $self }{ @fields };
}

sub exists { exists $_[0]->{ $_[1] } }
sub clear  { %{ $_[0] } = ()         }

sub field_names {
    my $self = shift;
    $adapter_of{ refaddr($self) }->field_names;
}

sub each {
    my ( $self, $callback ) = @_;

    if ( ref $callback eq 'CODE' ) {
        for my $field ( $self->field_names ) {
            $callback->( $field, $self->{ $field } );
        }
    }
    elsif ( defined wantarray ) { # deprecated
        return $self->_each;
    }
    else {
        croak( 'Must provide a code reference to each()' );
    }

    return;
}

# This method is deprecated and will be remove in 0.06
sub _each {
    my $self = shift;
    my $iter = $iterator_of{ refaddr($self) };

    if ( !%{ $iter } or $iter->{is_exhausted} ) {
        my @fields = $self->field_names;
        %{ $iter } = (
            collection => \@fields,
            size       => scalar @fields,
            current    => 0,
        );
    }

    if ( $iter->{current} < $iter->{size} ) {
        my $field = $iter->{collection}[ $iter->{current}++ ];
        return wantarray ? ( $field, $self->{ $field } ) : $field;
    }
    else {
        $iter->{is_exhausted}++;
    }

    return;
}

sub is_empty { not %{ $_[0] } }

sub flatten {
    my $self = shift;
    map { $_, $self->{$_} } $self->field_names;
}

sub set_cookie {
    my ( $self, $name, $value ) = @_;

    require CGI::Cookie;

    my $new_cookie = CGI::Cookie->new(do {
        my %args = ref $value eq 'HASH' ? %{ $value } : ( value => $value );
        $args{name} = $name;
        \%args;
    });

    my @cookies;
    my $offset = 0;
    if ( my $cookies = $self->{Set_Cookie} ) {
        @cookies = ref $cookies eq 'ARRAY' ? @{ $cookies } : $cookies;
        for my $cookie ( @cookies ) {
            last if ref $cookie eq 'CGI::Cookie' and $cookie->name eq $name;
            $offset++;
        }
    }

    # add/overwrite CGI::Cookie object
    splice @cookies, $offset, 1, $new_cookie;

    $self->{Set_Cookie} = @cookies > 1 ? \@cookies : $cookies[0];

    return;
}

sub get_cookie {
    my ( $self, $name ) = @_;

    my @values;
    if ( my $cookies = $self->{Set_Cookie} ) {
        @values = grep {
            ref $_ eq 'CGI::Cookie' and $_->name eq $name
        } (
            ref $cookies eq 'ARRAY' ? @{ $cookies } : $cookies,
        );
    }

    wantarray ? @values : $values[0];
}

# This method/function is obsolete and will be removed in 0.06
sub push_cookie {
    my $self = shift;

    require CGI::Cookie;

    my @cookies;
    for my $cookie ( @_ ) {
        $cookie = CGI::Cookie->new( $cookie ) if ref $cookie eq 'HASH';
        push @cookies, $cookie; 
    }

    $self->_push( Set_Cookie => @cookies );
}

# This method is obsolete and will be removed in 0.06
sub _push {
    my ( $self, $field, @values ) = @_;

    return carp( 'Useless use of _push() with no values' ) unless @values;

    if ( my $value = $self->{ $field } ) {
        return push @{ $value }, @values if ref $value eq 'ARRAY';
        unshift @values, $value;
    }

    $self->{ $field } = @values > 1 ? \@values : $values[0];

    scalar @values;
}

sub push_p3p_tags {
    my $self = shift;
    $adapter_of{ refaddr($self) }->push_p3p_tags( @_ );
}

*push_p3p = \&push_p3p_tags;

sub attachment {
    my $self = shift;
    $adapter_of{ refaddr($self) }->attachment( @_ );
}

sub nph {
    my $self = shift;
    $adapter_of{ refaddr($self) }->nph( @_ );
}

sub charset {
    my $self = shift;
    my $type = $self->{Content_Type};
    my ( $charset ) = $type =~ /charset=([^;]+)/ if $type;
    return unless $charset;
    uc $charset;
}

# This method is obsolete and will be removed in 0.06
sub cookie {
    my $self = shift;

    if ( @_ ) {
        delete $self->{Set_Cookie};
        $self->push_cookie( @_ );
    }
    elsif ( my $cookie = $self->{Set_Cookie} ) {
        my @cookies = ref $cookie eq 'ARRAY' ? @{ $cookie } : ( $cookie );
        return wantarray ? @cookies : $cookies[0];
    }

    return;
}

sub last_modified { shift->_date_header( Last_modified => $_[0] ) }
sub date          { shift->_date_header( Date => $_[0] )          }

sub _date_header {
    my ( $self, $field, $time ) = @_;

    if ( defined $time ) {
        return $self->{ $field } = _time2str( $time );
    }
    elsif ( my $date = $self->{ $field } ) {
        return _str2time( $date );
    }

    return;
}

sub expires {
    my $self = shift;
    return $self->{Expires} = shift if @_;
    my $expires = $adapter_of{ refaddr($self) }->expires;
    return unless $expires;
    _str2time( $expires );
}

sub p3p_tags {
    my $self = shift;
    $adapter_of{ refaddr($self) }->p3p_tags( @_ );
}

*p3p = \&p3p_tags;

sub content_type {
    my $self = shift;
    return $self->{Content_Type} = shift if @_;
    my $content_type = $self->{Content_Type};
    return q{} unless $content_type;
    my ( $type, $rest ) = split /;\s*/, $content_type, 2;
    wantarray ? ( lc $type, $rest ) : lc $type;
}

*type = \&content_type;

sub status {
    my $self = shift;

    if ( @_ ) {
        require HTTP::Status;
        my $code = shift;
        my $message = HTTP::Status::status_message( $code );
        return $self->{Status} = "$code $message" if $message;
        carp( qq{Unknown status code "$code" passed to status()} );
    }
    elsif ( my $status = $self->{Status} ) {
        return substr( $status, 0, 3 );
    }

    return;
}

sub target {
    my $self = shift;
    return $self->{Window_Target} = shift if @_;
    $self->{Window_Target};
}

my %str2time;
sub _str2time { $str2time{ $_[0] } ||= HTTP::Date::str2time( $_[0] ) }

my %time2str;
sub _time2str { $time2str{ $_[0] } ||= HTTP::Date::time2str( $_[0] ) }

1;

__END__

=head1 NAME

Blosxom::Header::Target - Base class for Blosxom::Header

=head1 DESCRIPTION

This class is the base class for L<Blosxom::Header>,
it is not used directly by callers.

=head1 SEE ALSO

L<Blosxom::Header>

=head1 MAINTAINER

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut


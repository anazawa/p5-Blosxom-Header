package Blosxom::Header::Entity;
use strict;
use warnings;
use overload '%{}' => 'as_hashref', 'fallback' => 1;
use Carp qw/carp croak/;
use List::Util qw/first/;
use Scalar::Util qw/refaddr/;

BEGIN {
    *clear  = \&CLEAR;
    *exists = \&EXISTS;
    *type   = \&content_type;
}

my ( %adapter_of, %adaptee_of );

sub new {
    my $class = shift;
    my $adaptee = ref $_[0] eq 'HASH' ? shift : {};
    my $self = tie my %adapter => $class => $adaptee;
    $adapter_of{ refaddr $self } = \%adapter;
    $self;
}

sub as_hashref { $adapter_of{ refaddr shift } }

sub get {
    my ( $self, @fields ) = @_;
    my @values = map { $self->FETCH($_) } @fields;
    wantarray ? @values : $values[0];
}

sub set {
    my ( $self, @headers ) = @_;

    if ( @headers % 2 == 0 ) {
        while ( my ($field, $value) = splice @headers, 0, 2 ) {
            $self->STORE( $field => $value );
        }
    }
    else {
        carp 'Odd number of elements passed to set()';
    }

    return;
}

sub delete {
    my ( $self, @fields ) = @_;

    if ( wantarray ) {
        return map { $self->DELETE($_) } @fields;
    }
    elsif ( defined wantarray ) {
        my $deleted = @fields && $self->DELETE( pop @fields );
        $self->DELETE( $_ ) for @fields;
        return $deleted;
    }
    else {
        $self->DELETE( $_ ) for @fields;
    }

    return;
}

sub is_empty { not shift->SCALAR }

sub each {
    my ( $self, $callback ) = @_;

    if ( ref $callback eq 'CODE' ) {
        for my $field ( $self->field_names ) {
            $callback->( $field, $self->FETCH($field) );
        }
    }
    else {
        croak 'Must provide a code reference to each()';
    }

    return;
}

sub charset {
    my $self = shift;

    require HTTP::Headers::Util;

    my %param = do {
        my $type = $self->FETCH( 'Content-Type' );
        my ( $params ) = HTTP::Headers::Util::split_header_words( $type );
        return unless $params;
        splice @{ $params }, 0, 2;
        @{ $params };
    };

    if ( my $charset = $param{charset} ) {
        $charset =~ s/^\s+//;
        $charset =~ s/\s+$//;
        return uc $charset;
    }

    return;
}

sub content_type {
    my $self = shift;

    if ( @_ ) {
        my $content_type = shift;
        $self->STORE( 'Content-Type' => $content_type );
        return;
    }

    my ( $media_type, $rest ) = do {
        my $content_type = $self->FETCH( 'Content-Type' );
        return q{} unless defined $content_type;
        split /;\s*/, $content_type, 2;
    };

    $media_type =~ s/\s+//g;
    $media_type = lc $media_type;

    wantarray ? ($media_type, $rest) : $media_type;
}

sub date          { shift->_date_header( 'Date',          @_ ) }
sub last_modified { shift->_date_header( 'Last-Modified', @_ ) }

sub _date_header {
    my ( $self, $field, $time ) = @_;

    require HTTP::Date;

    if ( defined $time ) {
        $self->STORE( $field => HTTP::Date::time2str($time) );
    }
    elsif ( my $date = $self->FETCH($field) ) {
        return HTTP::Date::str2time( $date );
    }

    return;
}

sub expires {
    my $self = shift;

    if ( @_ ) {
        $self->STORE( Expires => shift );
    }
    elsif ( my $expires = $self->FETCH('Expires') ) {
        require HTTP::Date;
        require CGI::Util;
        my $date = CGI::Util::expires( $expires );
        return HTTP::Date::str2time( $date );
    }

    return;
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
    if ( my $cookies = $self->FETCH('Set-Cookie') ) {
        @cookies = ref $cookies eq 'ARRAY' ? @{ $cookies } : $cookies;
        for my $cookie ( @cookies ) {
            next unless ref $cookie eq 'CGI::Cookie';
            next unless $cookie->name eq $name;
            $cookie = $new_cookie;
            undef $new_cookie;
            last;
        }
    }

    push @cookies, $new_cookie if $new_cookie;

    $self->STORE( 'Set-Cookie' => @cookies > 1 ? \@cookies : $cookies[0] );

    return;
}

sub get_cookie {
    my $self   = shift;
    my $name   = shift;
    my $cookie = $self->FETCH( 'Set-Cookie' );

    my @values = grep {
        ref $_ eq 'CGI::Cookie' and $_->name eq $name
    } (
        ref $cookie eq 'ARRAY' ? @{ $cookie } : $cookie,
    );

    wantarray ? @values : $values[0];
}

sub status {
    my $self = shift;

    require HTTP::Status;

    if ( @_ ) {
        my $code = shift;
        my $message = HTTP::Status::status_message( $code );
        return $self->STORE( Status => "$code $message" ) if $message;
        carp "Unknown status code '$code' passed to status()";
    }
    elsif ( my $status = $self->FETCH('Status') ) {
        return substr( $status, 0, 3 );
    }

    return;
}

sub target {
    my $self = shift;
    $self->STORE( 'Window-Target' => shift ) if @_;
    $self->FETCH( 'Window-Target' );
}

sub TIEHASH {
    my ( $class, $adaptee ) = @_;
    my $self = bless \do { my $anon_scalar }, $class;
    $adaptee_of{ refaddr $self } = $adaptee;
    $self;
}

sub FETCH {
    my $self   = shift;
    my $norm   = $self->_normalize( shift );
    my $header = $adaptee_of{ refaddr $self };

    if ( $norm eq '-content_type' ) {
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

        return $charset ? "$type; charset=$charset" : $type;
    }
    elsif ( $norm eq '-content_disposition' ) {
        if ( my $attachment = $header->{-attachment} ) {
            return qq{attachment; filename="$attachment"};
        }
    }
    elsif ( $norm eq '-date' ) {
        if ( $self->_date_header_is_fixed ) {
            require HTTP::Date;
            return HTTP::Date::time2str( time );
        }
    }
    elsif ( $norm eq '-p3p' ) {
        if ( my $p3p = $header->{-p3p} ) {
            my $tags = ref $p3p eq 'ARRAY' ? join ' ', @{ $p3p } : $p3p;
            return qq{policyref="/w3c/p3p.xml", CP="$tags"};
        }
        else {
            return;
        }
    }

    $header->{ $norm };
}

sub STORE {
    my $self   = shift;
    my $norm   = $self->_normalize( shift );
    my $value  = shift;
    my $header = $adaptee_of{ refaddr $self };

    if ( $norm eq '-date' ) {
        if ( $self->_date_header_is_fixed ) {
            return carp 'The Date header is fixed';
        }
    }
    elsif ( $norm eq '-content_type' ) {
        $header->{-charset} = q{};
        $header->{-type} = $value;
        return;
    }
    elsif ( $norm eq '-content_disposition' ) {
        delete $header->{-attachment};
    }
    elsif ( $norm eq '-expires' or $norm eq '-cookie' ) {
        delete $header->{-date};
    }
    elsif ( $norm eq '-p3p' ) {
        return;
    }

    $header->{ $norm } = $value;

    return;
}

sub DELETE {
    my $self    = shift;
    my $field   = shift;
    my $norm    = $self->_normalize( $field );
    my $deleted = defined wantarray && $self->FETCH( $field );
    my $header  = $adaptee_of{ refaddr $self };

    if ( $norm eq '-date' ) {
        if ( $self->_date_header_is_fixed ) {
            return carp 'The Date header is fixed';
        }
    }
    elsif ( $norm eq '-content_type' ) {
        delete $header->{-charset};
        $header->{-type} = q{};
    }
    elsif ( $norm eq '-content_disposition' ) {
        delete $header->{-attachment};
    }

    delete $header->{ $norm };

    $deleted;
}

sub CLEAR {
    my $self = shift;
    my $header = $adaptee_of{ refaddr $self };
    %{ $header } = ( -type => q{} );
    return;
}

sub EXISTS {
    my $self   = shift;
    my $norm   = $self->_normalize( shift );
    my $header = $adaptee_of{ refaddr $self };

    if ( $norm eq '-content_type' ) {
        return !defined $header->{-type} || $header->{-type} ne q{};
    }
    elsif ( $norm eq '-content_disposition' ) {
        return 1 if $header->{-attachment};
    }
    elsif ( $norm eq '-date' ) {
        return 1 if first { $header->{$_} } qw(-nph -expires -cookie);
    }

    $header->{ $norm };
}

sub SCALAR {
    my $self = shift;
    my $header = $adaptee_of{ refaddr $self };
    !defined $header->{-type} || first { $_ } values %{ $header };
}

sub UNTIE {
    my $self = shift;
    delete $adapter_of{ refaddr $self };
    return;
}

sub DESTROY {
    my $self = shift;
    my $this = refaddr $self;
    delete $adapter_of{ $this };
    delete $adaptee_of{ $this };
    return;
}

sub field_names {
    my $self   = shift;
    my $header = $adaptee_of{ refaddr $self };
    my %header = %{ $header }; # copy

    my @fields;

    push @fields, 'Status'        if delete $header{-status};
    push @fields, 'Window-Target' if delete $header{-target};
    push @fields, 'P3P'           if delete $header{-p3p};

    push @fields, 'Set-Cookie' if my $cookie  = delete $header{-cookie};
    push @fields, 'Expires'    if my $expires = delete $header{-expires};
    push @fields, 'Date' if delete $header{-nph} or $cookie or $expires;

    push @fields, 'Content-Disposition' if delete $header{-attachment};

    # not ordered
    my $type = delete @header{qw/-charset -type/};
    while ( my ($norm, $value) = CORE::each %header ) {
        push @fields, $self->_denormalize( $norm ) if $value;
    }

    push @fields, 'Content-Type' if !defined $type or $type ne q{};

    @fields;
}

sub flatten {
    my $self = shift;
    map { $_, $self->FETCH($_) } $self->field_names;
}

sub attachment {
    my $self   = shift;
    my $header = $adaptee_of{ refaddr $self };

    if ( @_ ) {
        delete $header->{-content_disposition};
        $header->{-attachment} = shift;
    }
    else {
        return $header->{-attachment};
    }

    return;
}

sub nph {
    my $self   = shift;
    my $header = $adaptee_of{ refaddr $self };
    
    if ( @_ ) {
        my $nph = shift;
        delete $header->{-date} if $nph;
        $header->{-nph} = $nph;
    }
    else {
        return $header->{-nph};
    }

    return;
}

sub p3p_tags {
    my $self   = shift;
    my $header = $adaptee_of{ refaddr $self };

    if ( my @tags = @_ ) {
        $header->{-p3p} = @tags > 1 ? \@tags : $tags[0];
    }
    elsif ( my $tags = $header->{-p3p} ) {
        my @tags = ref $tags eq 'ARRAY' ? @{ $tags } : split ' ', $tags;
        return wantarray ? @tags : $tags[0];
    }

    return;
}

sub push_p3p_tags {
    my $self = shift;
    my @tags = @_;
    my $header = $adaptee_of{ refaddr $self };

    unless ( @tags ) {
        carp 'Useless use of push_p3p_tags() with no values';
        return;
    }

    if ( my $tags = $header->{-p3p} ) {
        return push @{ $tags }, @tags if ref $tags eq 'ARRAY';
        unshift @tags, $tags;
    }

    $header->{-p3p} = @tags > 1 ? \@tags : $tags[0];

    scalar @tags;
}

sub _date_header_is_fixed {
    my $self = shift;
    my $header = $adaptee_of{ refaddr $self };
    $header->{-expires} || $header->{-cookie} || $header->{-nph};
}

sub dump {
    my $self = shift;

    require Data::Dumper;

    local $Data::Dumper::Terse  = 1;
    local $Data::Dumper::Indent = 1;

    my %self = (
        adaptee => $adaptee_of{ refaddr $self },
        adapter => { $self->flatten },
    );

    Data::Dumper::Dumper( \%self );
}

my %norm_of = (
    -attachment => q{},        -charset       => q{},
    -cookie     => q{},        -nph           => q{},
    -set_cookie => q{-cookie}, -target        => q{},
    -type       => q{},        -window_target => q{-target},
);

sub _normalize {
    my $class = shift;
    my $field = lc shift;

    # transliterate dashes into underscores
    $field =~ tr{-}{_};

    # add an initial dash
    $field = "-$field";

    exists $norm_of{$field} ? $norm_of{ $field } : $field;
}

my %field_name_of = (
    -attachment => 'Content-Disposition', -cookie => 'Set-Cookie',
    -p3p        => 'P3P',                 -target => 'Window-Target',
    -type       => 'Content-Type',
);

sub _denormalize {
    my ( $class, $norm ) = @_;

    unless ( exists $field_name_of{$norm} ) {
        ( my $field = $norm ) =~ s/^-//;
        $field =~ tr/_/-/;
        $field_name_of{ $norm } = ucfirst $field;
    }

    $field_name_of{ $norm };
}

1;

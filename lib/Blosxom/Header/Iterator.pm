package Blosxom::Header::Iterator;
use strict;
use warnings;

#sub new {
#    my $class  = shift;
#    my %header = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;

#    my @fields;

#    push @fields, 'Status'        if delete $header{-status};
#    push @fields, 'Window-Target' if delete $header{-target};
#    push @fields, 'P3P'           if delete $header{-p3p};

#    push @fields, 'Set-Cookie' if my $cookie  = delete $header{-cookie};
#    push @fields, 'Expires'    if my $expires = delete $header{-expires};
#    push @fields, 'Date' if delete $header{-nph} || $expires || $cookie;

#    push @fields, 'Content-Disposition' if delete $header{-attachment};

    # not ordered
#    delete $header{-charset};
#    my @others = grep { $header{ $_ } and $_ ne '-type' } keys %header;
#    push @fields, map { $class->denormalize( $_ ) } @others;

#    push @fields, 'Content-Type' if !exists $header{-type} or $header{-type};

#    my %self = (
#        collection => \@fields,
#        size       => scalar @fields,
#        current    => 0,
#    );

#    bless \%self, $class;
#}

#sub next {
#    my $self = shift;
#    return unless $self->has_next;
#    $self->{collection}->[ $self->{current}++ ];
#}

#sub has_next {
#    my $self = shift;
#    $self->{current} < $self->{size};
#}

use List::Util qw/first/;

my $CONTENT_TYPE = sub { !exists $_[0]->{-type} or $_[0]->{-type} };
my $DATE = sub { first { $_ } @{ $_[0] }{qw/-nph -cookie -expires/} };

sub new {
    my ( $class, $header ) = @_;

    my @collection = (
        [ 'Status' => sub { $header->{-status} } ],
        [ 'Window-Target' => sub { $header->{-target} } ],
        [ 'P3P' => sub { $header->{-p3p} } ],
        [ 'Set-Cookie' => sub { $header->{-p3p} } ],
    );


}

#sub new {
#    my ( $class, $iteratee ) = @_;
#    my $self = bless { iteratee => $iteratee, norm_of => {} }, $class;
#    $self->initialize;
#}

#sub next {
#    my $self = shift;

    #if ( $self->{iterated} ) {
    #    my $norm = each %{ $self->{buffer} };
    #    my $cond = delete $self->{buffer}->{$norm};
    #    return $self->denormalize( $norm ) if $cond->( $self->{iteratee} );
    #}
#    my $next;
#    unless ( $self->{iterated} ) {
#        my $field;
#        while ( my ($norm, $value) = each %{ $self->{iteratee} } ) {
#            next if !$value or $norm eq '-nph';
#            $field = $self->denormalize( $norm );
#            delete $self->{buffer}->{$field};
#            last;
#        }
#        $self->{iterated}++ unless $field;
#        $next = $field;
#    }


#    if ( !$next and $self->{iterated} and %{ $self->{buffer} } ) {
#        my $field = each %{ $self->{buffer} };
#        $field = each %{ $self->{buffer} } unless $field;
#        my $cond = delete $self->{buffer}->{$field};
        #my ( $field, $cond ) = each %{ $self->{buffer} };
        #return $self->denormalize( $norm ) if $cond->( $self->{iteratee} );
#        return $field if $cond->( $self->{iteratee} );
#    }

#    $next;
#}

#sub has_next {
#    my $self = shift;
    #my $has_next = $self->next;
    #$self->initialize if $has_next;
#    if ( my $has_next = $self->next ) {
#        my $norm = $self->{norm_of}{$has_next};
        #warn $norm;
#        if ( $has_next eq 'Content-Type' ) {
#            $self->{buffer}{$has_next} = $CONTENT_TYPE;
#        }
#        elsif ( $has_next eq 'Date' ) {
#            $self->{buffer}{$has_next} = $DATE;
#        }
#        else {
#            $self->{buffer}{$has_next} = sub { $_[0]->{ $norm } };
#        }
#        return 1;
#    }
#    return;
#}

#sub initialize {
#    my $self = shift;
#    keys %{ $self->{iteratee} };
#    $self->{buffer} = {
#        'Content-Type' => sub { !exists $_[0]->{-type} or $_[0]->{-type} },
#        'Date' => sub { first { $_ } @{ $_[0] }{qw/-nph -cookie -expires/} },
#    };
#    $self;
#}

#sub size    { shift->{size}    }
#sub current { shift->{current} }

my %field_name_of = (
    -type => 'Content-Type',
    -attachment => 'Content-Disposition',
    -p3p => 'P3P',
    -cookie => 'Set-Cookie',
    -target => 'Window-Target',
);

sub denormalize {
    my ( $self, $norm ) = @_;

    #return $field_name_of{ $norm } if exists $field_name_of{ $norm };
    if ( exists $field_name_of{ $norm } ) {
        my $field = $field_name_of{ $norm };
        $self->{norm_of}{$field} ||= $norm;
        return $field;
    }

    # get rid of an initial dash
    ( my $field = $norm ) =~ s/^-//;

    # transliterate underbars into dashes
    $field =~ tr/_/-/;

    #$field_name_of{ $norm } = ucfirst $field;
    $field = $field_name_of{ $norm } = ucfirst $field;
    $self->{norm_of}{$field} = $norm;
    $field;

}

1;

__END__

=head1 NAME

Blosxom::Header::Iterator - Iterates over CGI response headers

=head1 SYNOPSIS

  use Blosxom::Header::Iterator;

  my $iterator = Blosxom::Header::Iterator->new(
      -status     => '304 Not Modified',
      -attachment => 'genome.jpg',
      -type       => 'text/plain'
  );

  while ( $iterator->has_next ) {
      print $iterator->next, "\n";
  }

=head1 DESCRIPTION

Iterates over L<CGI> response headers.

=head2 METHODS

=over 4

=item $iterator = Blosxom::Header::Iterator->new( HashRef )

Creates a new Blosxom::Header::Iterator object.

=item $field = Blosxom::Header::Iterator->denormalize( $norm )

=item $bool = $iterator->has_next

Returns a Boolean value telling whether there are still more elements in the
iterator.

=item $field = $iterator->next

Increments the iterator and returns the next field name.

=item $size = $iterator->size

=item $current = $iterator->current

Returns the current index in the iterator.

=back

=head1 MAINTAINER

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

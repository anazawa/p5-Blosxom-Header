use strict;
use warnings;
use CGI;
use Test::More tests => 1;

package CGI::Header;
use overload q{""} => 'as_string', fallback => 1;
use parent 'Blosxom::Header::Entity';

sub as_string {
    my $self = shift;
    my $CRLF = $CGI::CRLF;

    my $result;
    $self->each(sub {
        my ( $field, $value ) = @_;
        my @values = ref $value eq 'ARRAY' ? @{ $value } : $value;
        $result .= "$field: $_$CRLF" for @values;
    });

    $result ? "$result$CRLF" : $CRLF x 2;
}

package main;

my $header = CGI::Header->new(
    -type           => 'text/plain; charset=utf-8',
    -target         => 'ResultsWindow',
    -content_length => '12345',
);

$header->set_cookie( foo => 'bar' );
$header->set_cookie( bar => 'baz' );

$header->attachment( 'genome.jpg' );
$header->status( 304 );
$header->expires( '+3M' );

is $header, CGI::header( $header->header );

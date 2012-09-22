use strict;
use warnings;
use CGI;
use Test::More tests => 1;

package CGI::Header;
use overload q{""} => 'as_string', fallback => 1;
use parent 'Blosxom::Header::Entity';

my $CRLF = $CGI::CRLF;

sub as_string {
    my $self = shift;

    my $result;

    if ( $self->nph ) {
        my $protocol = $ENV{SERVER_PROTOCOL} || 'HTTP/1.0';
        my $software = $ENV{SERVER_SOFTWARE} || 'cmdline';
        my $status   = $self->{Status}       || '200 OK';
        $result .= "$protocol $status$CRLF";
        $result .= "Server: $software$CRLF";
    }

    $self->each(sub {
        my ( $field, $value ) = @_;
        my @values = ref $value eq 'ARRAY' ? @{ $value } : $value;
        $result .= "$field: $_$CRLF" for @values;
    });

    $result ? "$result$CRLF" : $CRLF x 2;
}

package main;

my $header = CGI::Header->new( -nph => 1 );

$header->set(
    'Content-Type'  => 'text/plain; charset=utf-8',
    'Window-Target' => 'ResultsWindow',
);

$header->attachment( 'genome.jpg' );
$header->status( 304 );
$header->expires( '+3M' );

$header->set_cookie( foo => 'bar' );
$header->set_cookie( bar => 'baz' );

$header->{'Content-Type'} = 12345;

is $header, CGI::header( $header->header );

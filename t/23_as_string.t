use strict;
use warnings;
use Blosxom::Header;
use CGI qw/header/;
use Test::More tests => 2;

my %header;
$blosxom::header = \%header;

package Blosxom::Header;

sub as_string {
    my $self = shift;

    my $result;
    $self->each(sub {
        my ( $field, $value ) = @_;
        $result .= "$field: $value$CGI::CRLF";
    });

    $result ? "$result$CGI::CRLF" : $CGI::CRLF x 2;
}

package main;

my $header = Blosxom::Header->instance;
is $header->as_string, header( $blosxom::header );

%header = (
    -type       => 'text/plain',
    -charset    => 'utf-8',
    -attachment => 'genome.jpg',
    -target     => 'ResultsWindow',
    -foo        => 'bar',
    -status     => '304 Not Modified',
    -cookie     => 'ID=123456; path=/',
);

is $header->as_string, header( $blosxom::header );

use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header();
    my $expected = "Content-Type: text/html; charset=ISO-8859-1$CGI::CRLF" .
                    $CGI::CRLF;
    is $got, $expected, 'default';
}

done_testing;

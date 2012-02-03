use strict;
use Test::More;
use CGI;

my $crlf = $CGI::CRLF;

{
    my $q = CGI->new;
    is $q->header(-type => 'text/plain'),
        "Content-Type: text/plain; charset=ISO-8859-1$crlf".
        $crlf;
}

{
    my $q = CGI->new;
    is $q->header(-charset => 'utf-8'),
        "Content-Type: text/html; charset=utf-8$crlf".
        $crlf;
}

{
    my $q = CGI->new;
    is $q->header(-attachment => 'foo.png'),
        qq{Content-Disposition: attachment; filename="foo.png"$crlf}.
        "Content-Type: text/html; charset=ISO-8859-1$crlf".
        $crlf;
}

{
    my $q = CGI->new;
    is $q->header(-p3p => 'foo bar'),
        qq{P3P: policyref="/w3c/p3p.xml", CP="foo bar"$crlf}.
        "Content-Type: text/html; charset=ISO-8859-1$crlf".
        $crlf;
    is $q->header(-p3p => 'foo bar'), $q->header(-p3p => [qw(foo bar)]);
}

done_testing;

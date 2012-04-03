use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header({ p3p => "CAO DSP LAW CURa" });
    my $expected = qq{P3P: policyref="/w3c/p3p.xml", CP="CAO DSP LAW CURa"}
                 . $CGI::CRLF
                 . "Content-Type: text/html; charset=ISO-8859-1$CGI::CRLF"
                 . $CGI::CRLF;
    is $got, $expected, 'p3p';
}

{
    my $q = CGI->new;
    my $got = $q->header({ p3p => [ qw/CAO DSP LAW CURa/ ] });
    my $expected = qq{P3P: policyref="/w3c/p3p.xml", CP="CAO DSP LAW CURa"}
                 . $CGI::CRLF
                 . "Content-Type: text/html; charset=ISO-8859-1$CGI::CRLF"
                 . $CGI::CRLF;
    is $got, $expected, 'p3p arrayref';
}

{
    my $q = CGI->new;
    my $got = $q->header({
        P3P => qq{policyref="/w3c/p3p.xml", CP="CAO DSP LAW CURa"},
    });
    my $expected = qq{P3P: policyref="/w3c/p3p.xml", CP="}
                 . qq{policyref="/w3c/p3p.xml", CP="CAO DSP LAW CURa"}
                 . qq{"$CGI::CRLF}
                 . "Content-Type: text/html; charset=ISO-8859-1$CGI::CRLF"
                 . $CGI::CRLF;
    is $got, $expected, 'p3p raw'; # doesn't work
}

{
    my $q = CGI->new;
    my $got = $q->header({ p3p => q{} });
    my $expected = "Content-Type: text/html; charset=ISO-8859-1$CGI::CRLF"
                 . $CGI::CRLF;
    is $got, $expected, 'p3p empty string';
}

done_testing;

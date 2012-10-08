use strict;
use warnings;
use Blosxom::Header;
use Test::More tests => 2;

my %header;
$blosxom::header = \%header;
my $header = Blosxom::Header->instance;

subtest 'charset()' => sub {
    %header = ();
    is $header->charset, 'ISO-8859-1';

    $header->{Content_Type} = 'text/plain';
    is $header->charset, undef;

    delete $header->{Content_Type};
    is $header->charset, undef;

    $header->{Content_Type} = 'text/html; charset=euc-jp';
    is $header->charset, 'EUC-JP';

    $header->{Content_Type} = 'text/html; charset=iso-8859-1; Foo=1';
    is $header->charset, 'ISO-8859-1';

    $header->{Content_Type} = 'text/html; charset="iso-8859-1"; Foo=1';
    is $header->charset, 'ISO-8859-1';

    $header->{Content_Type} = 'text/html; charset = "iso-8859-1"; Foo=1';
    is $header->charset, 'ISO-8859-1';

    $header->{Content_Type} = 'text/html;\r\n charset = "iso-8859-1"; Foo=1';
    is $header->charset, 'ISO-8859-1';

    $header->{Content_Type} = 'text/html;\r\n charset = iso-8859-1 ; Foo=1';
    is $header->charset, 'ISO-8859-1';

    $header->{Content_Type} = 'text/html;\r\n charset = iso-8859-1 ';
    is $header->charset, 'ISO-8859-1';
};

subtest 'content_type()' => sub {
    %header = ();
    is $header->content_type, 'text/html';
    my @got = $header->content_type;
    my @expected = ( 'text/html', 'charset=ISO-8859-1' );
    is_deeply \@got, \@expected;

    $header->{Content_Type} = 'text/plain; charset=EUC-JP; Foo=1';
    is $header->content_type, 'text/plain';
    @got = $header->content_type;
    @expected = ( 'text/plain', 'charset=EUC-JP; Foo=1' );
    is_deeply \@got, \@expected;

    $header->content_type( 'text/plain; charset=EUC-JP' );
    is $header->{Content_Type}, 'text/plain; charset=EUC-JP';

    delete $header->{Content_Type};
    is $header->content_type, q{};

    $header->{Content_Type} = '   TEXT  / HTML   ';
    is $header->content_type, 'text/html';
};

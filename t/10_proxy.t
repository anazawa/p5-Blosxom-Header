use strict;
use Blosxom::Header::Proxy;
use Test::Exception;
use Test::More tests => 11;

{
    package blosxom;
    our $header;
}

my $proxy = tie my %proxy => 'Blosxom::Header::Proxy';
isa_ok $proxy, 'Blosxom::Header::Proxy';
can_ok $proxy, qw(
    FETCH STORE DELETE EXISTS CLEAR FIRSTKEY NEXTKEY SCALAR
    header is_initialized field_names
);

subtest 'is_initialized()' => sub {
    local $blosxom::header;
    ok !$proxy->is_initialized, 'should return false';

    $blosxom::header = {};
    ok $proxy->is_initialized, 'should return true';
};

subtest 'header()' => sub {
    local $blosxom::header;
    my $expected = qr/^\$blosxom::header hasn't been initialized yet/;
    throws_ok { $proxy->header } $expected, 'header() throws an exception';

    $blosxom::header = {};
    is $proxy->header, $blosxom::header,
        'header() returns the same reference as $blosxom::header';
};

subtest 'SCALAR()' => sub {
    local $blosxom::header = { -type => q{} };
    ok !%proxy;

    $blosxom::header = { -type => q{}, -charset => 'utf-8' };
    ok !%proxy;

    $blosxom::header = { -type => q{}, -foo => 'bar' };
    ok %proxy;

    $blosxom::header = {};
    ok %proxy;

    $blosxom::header = { -foo => 'bar' };
    ok %proxy;
};

subtest 'CLEAR()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    %proxy = ();
    is_deeply $blosxom::header, { -type => q{} };
};

subtest 'EXISTS()' => sub {
    local $blosxom::header = { -foo => 'bar' };
    ok exists $proxy{Foo};
    ok !exists $proxy{Bar};

    $blosxom::header = { -type => q{} };
    ok !exists $proxy{Content_Type};
    ok exists $proxy{-type};

    $blosxom::header = {};
    ok exists $proxy{Content_Type};
    ok !exists $proxy{-type};

    $blosxom::header = { -type => 'foo' };
    ok exists $proxy{Content_Type};
    ok exists $proxy{-type};

    $blosxom::header = { -type => undef };
    ok exists $proxy{Content_Type};
    ok exists $proxy{-type};

    $blosxom::header = { -attachment => 'foo' };
    ok exists $proxy{Content_Disposition};
    ok exists $proxy{-attachment};

    $blosxom::header = { -attachment => q{} };
    ok !exists $proxy{Content_Disposition};
    ok exists $proxy{-attachment};

    $blosxom::header = { -attachment => undef };
    ok !exists $proxy{Content_Disposition};
    ok exists $proxy{-attachment};
};

subtest 'DELETE()' => sub {
    local $blosxom::header = { -foo => 'bar', -bar => 'baz' };
    is delete $proxy{Foo}, 'bar';
    is_deeply $blosxom::header, { -bar => 'baz' };

    $blosxom::header = {};
    is delete $proxy{Content_Type}, 'text/html; charset=ISO-8859-1';
    is_deeply $blosxom::header, { -type => q{} };

    $blosxom::header = { -type => q{} };
    is delete $proxy{Content_Type}, undef;
    is_deeply $blosxom::header, { -type => q{} };

    $blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    is delete $proxy{Content_Type}, 'text/plain; charset=utf-8';
    is_deeply $blosxom::header, { -type => q{} };

    $blosxom::header = { -attachment => 'foo' };
    is delete $proxy{Content_Disposition}, 'attachment; filename="foo"';
    is_deeply $blosxom::header, {};

    $blosxom::header = { -attachment => 'foo' };
    is delete $proxy{-attachment}, 'foo';
    is_deeply $blosxom::header, {};
};

subtest 'FETCH()' => sub {
    local $blosxom::header = {};
    is $proxy{Content_Type}, 'text/html; charset=ISO-8859-1';
    is $proxy{-type}, undef;
    is $proxy{-charset}, undef;

    $blosxom::header = { -type => 'text/plain' };
    is $proxy{Content_Type}, 'text/plain; charset=ISO-8859-1';
    is $proxy{-type}, 'text/plain';
    is $proxy{-charset}, undef;

    $blosxom::header = { -charset => 'utf-8' };
    is $proxy{Content_Type}, 'text/html; charset=utf-8';
    is $proxy{-type}, undef;
    is $proxy{-charset}, 'utf-8';

    $blosxom::header = { -type => 'text/plain', -charset => 'utf-8' };
    is $proxy{Content_Type}, 'text/plain; charset=utf-8';
    is $proxy{-type}, 'text/plain';
    is $proxy{-charset}, 'utf-8';

    $blosxom::header = { -type => q{} };
    is $proxy{Content_Type}, undef;
    is $proxy{-type}, q{};
    is $proxy{-charset}, undef;

    $blosxom::header = { -type => q{}, -charset => 'utf-8' };
    is $proxy{Content_Type}, undef;
    is $proxy{-type}, q{};
    is $proxy{-charset}, 'utf-8';

    $blosxom::header = { -type => 'text/plain; charset=EUC-JP' };
    is $proxy{Content_Type}, 'text/plain; charset=EUC-JP';
    is $proxy{-type}, 'text/plain; charset=EUC-JP';
    is $proxy{-charset}, undef;

    $blosxom::header = {
        -type    => 'text/plain; charset=euc-jp',
        -charset => 'utf-8',
    };
    is $proxy{Content_Type}, 'text/plain; charset=euc-jp';
    is $proxy{-type}, 'text/plain; charset=euc-jp';
    is $proxy{-charset}, 'utf-8';

    $blosxom::header = { -charset => q{} };
    is $proxy{Content_Type}, 'text/html';
    is $proxy{-type}, undef;
    is $proxy{-charset}, q{};

    $blosxom::header = { -attachment => 'foo' };
    is $proxy{Content_Disposition}, 'attachment; filename="foo"';
    is $proxy{-attachment}, 'foo';
};

subtest 'STORE()' => sub {
    local $blosxom::header = {};
    $proxy{Foo} = 'bar';
    is_deeply $blosxom::header, { -foo => 'bar' };
    
    $blosxom::header = { -attachment => 'foo' };
    $proxy{Content_Disposition} = 'inline';
    is_deeply $blosxom::header, { -content_disposition => 'inline' };
    
    $blosxom::header = { -content_disposition => 'inline' };
    $proxy{-attachment} = 'genome.jpg';
    is_deeply $blosxom::header, { -attachment => 'genome.jpg' };

    $blosxom::header = { -charset => 'euc-jp' };
    $proxy{Content_Type} = 'text/plain; charset=utf-8';
    is_deeply $blosxom::header, { -type => 'text/plain; charset=utf-8' };

    $blosxom::header = { -charset => 'euc-jp' };
    $proxy{Content_Type} = 'text/plain';
    is_deeply $blosxom::header, { -type => 'text/plain', -charset => q{} };

    $blosxom::header = { -charset => 'euc-jp' };
    $proxy{-type} = 'text/plain; charset=utf-8';
    is_deeply $blosxom::header, {
        -type    => 'text/plain; charset=utf-8',
        -charset => 'euc-jp',
    };

    $blosxom::header = { -charset => 'euc-jp' };
    $proxy{-type} = 'text/plain';
    is_deeply $blosxom::header, { -type => 'text/plain', -charset => 'euc-jp' };
};

subtest 'field_names()' => sub {
    local $blosxom::header = {
        -nph        => 'foo',
        -charset    => 'foo',
        -status     => 'foo',
        -target     => 'foo',
        -p3p        => 'foo',
        -cookie     => 'foo',
        -expires    => 'foo',
        -attachment => 'foo',
        -foo_bar    => 'foo',
    };

    my @got = sort $proxy->field_names;

    my @expected = qw(
        Content-Disposition
        Content-Type
        Expires
        Foo-bar
        P3P
        Set-Cookie
        Status
        Window-Target
    );

    is_deeply \@got, \@expected;
};

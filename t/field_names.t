use strict;
use Blosxom::Header;
use Test::More;

{
    my $header = Blosxom::Header->new({});

    $header->set(
        Foo_Bar    => 'bar',
        Bar_Baz    => 'baz',
        type       => 'text/plain',
        attachment => 'foo.png',
        status     => '304 Not Modified',
        p3p        => 'foo',
        cookie     => 'foo',
        expires    => 'Expires',
        target     => 'foo',
        charset    => 'utf-8',
        nph        => 1,
    );

    my @got = sort $header->keys;

    my @expected = qw(
        Bar-baz
        Foo-bar
        attachment
        charset
        cookie
        expires
        nph
        p3p
        status
        target
        type
    );

    is_deeply \@got, \@expected, 'field_names';
}

done_testing;

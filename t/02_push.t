use strict;
use Test::More;
use Blosxom::Header;

{
    my $headers = {};
    my $h = Blosxom::Header->new($headers);
    $h->push_cookie('foo');
    #is_deeply $headers, { -cookie => 'foo' };
    is_deeply $headers, { cookie => 'foo' };
}

{
    my $headers = { -cookie => 'foo' };
    my $h = Blosxom::Header->new($headers);
    $h->push_cookie('bar');
    is_deeply $headers, { -cookie => ['foo', 'bar'] };
}

{
    my $headers = { -cookie => ['foo', 'bar'] };
    my $h = Blosxom::Header->new($headers);
    $h->push_cookie('baz');
    is_deeply $headers, { -cookie => ['foo', 'bar', 'baz'] };
}

done_testing;

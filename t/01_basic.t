use strict;
use Test::More;
use Test::Warn;
use Blosxom::Header qw(headers);

{
    my $headers;
    warning_is { headers($headers) }
        { carped => q{Given variable hasn't been initialized yet.} };
}

{
    my $headers = { '-foo' => 'bar' };
    is_deeply headers($headers), { headers => $headers };
}

{
    my $headers = { '-foo' => 'bar' };
    headers($headers)->set(foo => 'baz');
    is_deeply $headers, { '-foo' => 'baz' };
}

{
    my $headers = { '-foo' => 'bar' };
    headers($headers)->set(bar => 'baz');
    is_deeply $headers, { '-foo' => 'bar', '-bar' => 'baz' };
}

{
    my $headers = { '-foo' => 'bar' };
    headers($headers)->set(Foo => 'baz');
    is_deeply $headers, { '-foo' => 'baz' }, 'set case-sensitive';
}

{
    my $headers = { '-foo' => 'bar' };
    is headers($headers)->get('foo'), 'bar';
}

{
    my $headers = { '-foo' => 'bar' };
    is headers($headers)->get('Foo'), 'bar', 'get case-sensitive';
}

{
    my $headers = { '-foo' => 'bar', '-bar' => 'baz' };
    headers($headers)->remove('foo');
    is_deeply $headers, { '-bar' => 'baz' };
}

{
    my $headers = { '-foo' => 'bar', '-bar' => 'baz' };
    headers($headers)->remove('Foo');
    is_deeply $headers, { '-bar' => 'baz' }, 'remove case-sensitive';
}

{
    my $headers = { '-foo' => 'bar', '-bar' => 'baz' };
    is headers($headers)->exists('foo'), 1;
}

{
    my $headers = { '-foo' => 'bar', '-bar' => 'baz' };
    is headers($headers)->exists('Foo'), 1, 'exists case-sensitive';
}

done_testing;

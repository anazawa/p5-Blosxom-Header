use strict;
use Test::More;
use Blosxom::Header;

{
    my $headers = { '-cookie' => ['foo=bar', 'bar=baz'] };
    my $h = Blosxom::Header->new($headers);
    is $h->get('Set-Cookie'), 'foo=bar';

    my @v = $h->get('Set-Cookie');
    is_deeply \@v, ['foo=bar', 'bar=baz'];
}

{
    my $headers = { '-cookie' => 'foo=bar' };
    my $h = Blosxom::Header->new($headers);
    $h->push_cookie('bar=baz');
    is_deeply $headers, { '-cookie' => ['foo=bar', 'bar=baz'] };
}

{
    my $headers = { '-type' => 'text/html', '-cookie' => 'foo=bar'  };
    my $c = Blosxom::Header->new($headers);
    $c->remove('Set-Cookie');
    is_deeply $headers, { '-type' => 'text/html' };
}

done_testing;

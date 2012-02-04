use strict;
use Test::More;
use Blosxom::Header;

is Blosxom::Header::_lc('-foo'), 'foo';
is Blosxom::Header::_lc('-Foo'), 'foo';
is Blosxom::Header::_lc('foo'),  'foo';
is Blosxom::Header::_lc('Foo'),  'foo';

done_testing;

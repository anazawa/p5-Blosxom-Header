use strict;
use Test::More tests => 4;

BEGIN {
    use_ok 'Blosxom::Header';
    use_ok 'Blosxom::Header::Util';
}

can_ok 'Blosxom::Header', qw( instance new has_instance TIEHASH );
can_ok 'Blosxom::Header::Util', qw( time2str str2time expires );

use strict;
use Test::More tests => 6;

BEGIN {
    use_ok 'Blosxom::Header';
    use_ok 'Blosxom::Header::Proxy';
    use_ok 'Blosxom::Header::Entity';
}

can_ok 'Blosxom::Header', qw( instance has_instance );
can_ok 'Blosxom::Header::Proxy', qw( TIEHASH );
can_ok 'Blosxom::Header::Entity', qw( new );

use strict;
use Test::More tests => 2;

BEGIN {
    my $class = 'Blosxom::Header';
    use_ok $class;
    #can_ok $class, qw(instance _normalize_field_name TIEHASH);
    can_ok $class, qw(instance TIEHASH);
}

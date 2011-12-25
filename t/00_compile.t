use strict;
use Test::More tests => 3;

BEGIN {
    use_ok 'Blosxom::Headers';
}

my @methods = qw(new get exists remove set);
my $header  = Blosxom::Headers->new();

isa_ok($header, 'Blosxom::Headers');
can_ok($header, @methods);


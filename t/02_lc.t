use strict;
use Test::More;
use Blosxom::Header;

my @tests = (
    [qw(-foo foo)],
    [qw(-Foo foo)],
    [qw(foo  foo)],
    [qw(Foo  foo)],
);

for my $test (@tests) {
    my ($input, $output) = @$test;
    is Blosxom::Header::_lc($input), $output;
}

done_testing;

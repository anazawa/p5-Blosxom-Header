use strict;
use Blosxom::Header::Iterator;
use Test::Base;

plan tests => 1 * blocks();

my $iterator = Blosxom::Header::Iterator->new( collection => {} );

run {
    my $block = shift;
    is $iterator->denormalize( $block->input ), $block->expected;
};

__DATA__
===
--- input:    -foo
--- expected: Foo
===
--- input:    -foo_bar
--- expected: Foo-bar

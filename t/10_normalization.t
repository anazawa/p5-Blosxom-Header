use strict;
use Blosxom::Header::Adapter;
use Test::Base;

plan tests => 1 * blocks();

my $normalize = Blosxom::Header::Adapter->TIEHASH->{normalize};

run {
    my $block = shift;
    is $normalize->( $block->input ), $block->expected;
};

__DATA__
===
--- input:    -foo
--- expected: -foo
===
--- input:    -Foo
--- expected: -foo
===
--- input:    foo
--- expected: -foo
===
--- input:    Foo
--- expected: -foo
===
--- input:    -foo-bar
--- expected: -foo_bar
===
--- input:    -Foo-bar
--- expected: -foo_bar
===
--- input:    -Foo-Bar
--- expected: -foo_bar
===
--- input:    -foo_bar
--- expected: -foo_bar
===
--- input:    -Foo_bar
--- expected: -foo_bar
===
--- input:    -Foo_Bar
--- expected: -foo_bar
===
--- input:    foo-bar
--- expected: -foo_bar
===
--- input:    Foo-bar
--- expected: -foo_bar
===
--- input:    Foo-Bar
--- expected: -foo_bar
===
--- input:    foo_bar
--- expected: -foo_bar
===
--- input:    Foo_bar
--- expected: -foo_bar
===
--- input:    Foo_Bar
--- expected: -foo_bar
===
--- input:    -cookie
--- expected:
===
--- SKIP
--- input:    -cookies
--- expected:
===
--- input:    -set_cookie
--- expected: -cookie
===
--- input:    -window_target
--- expected: -target
===
--- input:    -target
--- expected:
===
--- input:    -attachment
--- expected: 
===
--- input:    -content_disposition
--- expected: -content_disposition
===
--- input:    -p3p
--- expected: -p3p
===
--- input:    -charset
--- expected: 
===
--- input:    -nph
--- expected: 
===
--- input:    -type
--- expected: 

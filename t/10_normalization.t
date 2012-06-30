use strict;
use Blosxom::Header::Normalizer;
use Test::Base;

plan tests => blocks() + 5;

my $normalizer = Blosxom::Header::Normalizer->new;
isa_ok $normalizer, 'Blosxom::Header::Normalizer';
can_ok $normalizer, qw( normalize is_normalized denormalize );

run {
    my $block = shift;
    is $normalizer->normalize( $block->input ), $block->expected;
};

ok $normalizer->is_normalized( '-foo_bar' );
ok !$normalizer->is_normalized( 'Foo-Bar' );

is $normalizer->denormalize( '-foo_bar' ), 'Foo-bar';

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

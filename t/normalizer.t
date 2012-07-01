use strict;
use Blosxom::Header::Normalizer;
use Test::More tests => 5;

my $normalizer = Blosxom::Header::Normalizer->new;
isa_ok $normalizer, 'Blosxom::Header::Normalizer';
#can_ok $normalizer, qw( normalize is_normalized denormalize );
can_ok $normalizer, qw( normalize is_normalized );

is $normalizer->normalize( 'Foo' ), '-foo';
ok $normalizer->is_normalized( '-foo' );
ok !$normalizer->is_normalized( 'Foo' );
#is $normalizer->denormalize( 'foo' ), 'Foo';

use strict;
use Blosxom::Header::Entity;
use Test::More tests => 3;

{
    package blosxom;
    our $header;
}

my $entity = Blosxom::Header::Entity->new;
isa_ok $entity, 'Blosxom::Header::Entity';
can_ok $entity, qw(
    header is_initialized reset_iterator
    normalize denormalize
);

subtest 'is_initialized()' => sub {
    undef $blosxom::header;
    ok !$entity->is_initialized, 'should return false';

    %{ $blosxom::header } = ();
    ok $entity->is_initialized, 'should return true';
};

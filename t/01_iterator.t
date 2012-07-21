use strict;
use warnings;
use Test::More tests => 7;

BEGIN {
    use_ok 'Blosxom::Header::Iterator';
}

my $class = 'Blosxom::Header::Iterator';
ok $class->can( 'new' );

my %iteratee;
my $iterator = $class->new( \%iteratee );
ok $iterator->isa( $class );
can_ok $iterator, qw( initialize next has_next denormalize );

ok $iterator->denormalize( '-foo' )     eq 'Foo';
ok $iterator->denormalize( '-foo_bar' ) eq 'Foo-bar';

%iteratee = (
    -status     => 1,
    -target     => 1,
    -p3p        => 1,
    -cookie     => 1,
    -expires    => 1,
    -nph        => 1,
    -attachment => 1,
    -foo        => 1,
    -type       => 1,
);

$iterator->initialize;

my @got;
while ( $iterator->has_next ) {
    push @got, $iterator->next;
}

my @expected = qw(
    Status
    Window-Target
    P3P
    Set-Cookie
    Expires
    Date
    Content-Disposition
    Foo
    Content-Type
);

is_deeply \@got, \@expected;

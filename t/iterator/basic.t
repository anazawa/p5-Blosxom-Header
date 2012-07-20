use strict;
use Blosxom::Header::Iterator;
use Test::More tests => 2;

my %iteratee;
my $iterator = Blosxom::Header::Iterator->new( collection => \%iteratee );
isa_ok $iterator, 'Blosxom::Header::Iterator';
can_ok $iterator, qw( initialize next has_next reset denormalize );

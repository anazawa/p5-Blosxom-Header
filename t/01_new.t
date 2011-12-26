use strict;
use Test::More tests => 2;
use Blosxom::Header;

my $header  = Blosxom::Header->new();
my @methods = qw(new get exists remove remove_all keys set);

isa_ok($header, 'Blosxom::Header' );
can_ok($header,  @methods         );


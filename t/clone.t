use strict;
use warnings;
use Blosxom::Header::Entity;

warn 'before';

{
    my $h = Blosxom::Header::Entity->new;
}

warn 'after'

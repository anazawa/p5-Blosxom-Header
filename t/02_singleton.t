use strict;
use Blosxom::Header;
use Test::More tests => 5;

{
    package blosxom;
    our $header = {};
}

package DerivedHeader;
use base 'Blosxom::Header';

sub _normalize_field_name {
    my $self = shift;
    my $norm = $self->SUPER::_normalize_field_name( shift );
    $norm =~ s/^-//;
    $norm;
}

package main;

ok !$Blosxom::Header::INSTANCE, 'no Blosxom::Header instance yet';

my $h1 = Blosxom::Header->instance;
ok $h1, 'created Blosxom::Header instance 1';

my $h2 = Blosxom::Header->instance;
ok $h2, 'created Blosxom::Header instance 2';

is $h1, $h2, 'both instances are the same object';
is $Blosxom::Header::INSTANCE, $h1, 'Blosxom::Header has instance';

#ok !$DerivedHeader::INSTANCE, 'no DerivedHeader instance yet';

#my $h3 = DerivedHeader->instance;
#ok $h3, 'created DerivedHeader instance 1';
#use Data::Dumper;
#die Dumper( $h3 );

#my $h4 = DerivedHeader->instance;
#ok $h4, 'created DerivedHeader instance 2';

#is $h3, $h4, 'both instances are the same object';
#is $DerivedHeader::INSTANCE, $h3, 'DerivedHeader has instance';

#isnt $h1, $h3, 'Blosxom::Header and DerivedHeader are different';


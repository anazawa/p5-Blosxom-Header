use strict;
use warnings;
use Blosxom::Header::Entity;
use Test::More tests => 2;
use Test::Warn;

my %header;
my $header = Blosxom::Header::Entity->new( \%header );

subtest 'status()' => sub {
    %header = ();
    is $header->status, undef;

    $header->status( 304 );
    is $header{-status}, '304 Not Modified';
    is $header->status, '304';

    my $expected = q{Unknown status code '999' passed to status()};
    warning_is { $header->status( 999 ) } $expected;
};

subtest 'target()' => sub {
    %header = ();
    is $header->target, undef;

    $header->target( 'ResultsWindow' );
    is $header->target, 'ResultsWindow';
    is_deeply \%header, { -target => 'ResultsWindow' };
};

use strict;
use Blosxom::Header::Entity;
use HTTP::Date;
use Test::More tests => 3;
use Test::Warn;

my %adaptee;
my $adapter = Blosxom::Header::Entity->new( \%adaptee );

subtest 'date()' => sub {
    %adaptee = ();
    is $adapter->date, undef;

    my $now = 1341637509;
    $adapter->date( $now );
    is $adapter->date, $now;
    is $adaptee{-date}, 'Sat, 07 Jul 2012 05:05:09 GMT';
};

subtest 'last_modified()' => sub {
    %adaptee = ();
    is $adapter->last_modified, undef;

    my $now = 1341637509;
    $adapter->last_modified( $now );
    is $adapter->last_modified, $now;
    is $adaptee{-last_modified}, 'Sat, 07 Jul 2012 05:05:09 GMT';
};

subtest 'expires()' => sub {
    %adaptee = ( -date => 'Sat, 07 Jul 2012 05:05:09 GMT' );
    #$adapter{Expires} = '+3M';
    $adapter->expires( '+3M' );
    is_deeply \%adaptee, { -expires => '+3M' };

    %adaptee = ();
    is $adapter->expires, undef;

    my $now = 1341637509;
    $adapter->expires( $now );
    is $adapter->expires, $now, 'get expires()';
    is $adaptee{-expires}, $now;

    $now++;
    $adapter->expires( 'Sat, 07 Jul 2012 05:05:10 GMT' );
    is $adapter->expires, $now, 'get expires()';
    is $adaptee{-expires}, 'Sat, 07 Jul 2012 05:05:10 GMT';
};

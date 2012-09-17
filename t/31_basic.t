use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;

BEGIN {
    my @functions = qw(
        header_get    header_set  header_exists
        header_delete header_iter
    );

    use_ok 'Blosxom::Header', @functions;
    can_ok __PACKAGE__, @functions;
}

my $class = 'Blosxom::Header';

can_ok $class, qw( instance has_instance new );

ok $class->isa( 'Blosxom::Header::Entity' );

subtest 'instance()' => sub {
    local $blosxom::header;
    ok !$class->is_initialized;

    my $expected = qr{^Blosxom::Header hasn't been initialized yet};
    throws_ok { $class->instance } $expected;

    $blosxom::header = {};
    ok $class->is_initialized;
};

# initialize
my %header;
$blosxom::header = \%header;

my $header = $class->instance;
isa_ok $header, 'Blosxom::Header';

subtest 'functions' => sub {
    %header = ();

    is header_get( 'Content-Type' ), 'text/html; charset=ISO-8859-1';
    is header_get( 'Status' ), undef;

    ok header_exists( 'Content-Type' );
    ok !header_exists( 'Status' );

    header_set( Status => '304 Not Modified' );
    is_deeply \%header, { -status => '304 Not Modified' };

    is header_delete( 'Status' ), '304 Not Modified';
    is_deeply \%header, {};

    my @got;
    header_iter sub {
        my ( $field, $value ) = @_;
        push @got, $field, $value;
    };

    my @expected = ( 'Content-Type', 'text/html; charset=ISO-8859-1' );

    is_deeply \@got, \@expected;
};

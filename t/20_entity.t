use strict;
use warnings;
use Blosxom::Header;
use Test::More tests => 10;
use Test::Warn;
use Test::Exception;

my $class = 'Blosxom::Header';

ok $class->isa( 'CGI::Header' );

can_ok $class, qw(
    new delete exists get set as_hashref
    content_type type charset date status
    DESTROY
);

# initialize
my %header;
$blosxom::header = \%header;
my $header = $class->instance( \%header );

# get()
%header = ( -foo => 'bar', -bar => 'baz' );
is $header->get('Foo', 'Bar'), 'baz';
is_deeply [ $header->get('Foo', 'Bar') ], [ 'bar', 'baz' ];

subtest 'set()' => sub {
    my $expected = qr{^Odd number of elements passed to set\(\)};
    throws_ok { $header->set('Foo') } $expected;

    %header = ();

    $header->set(
        Foo => 'bar',
        Bar => 'baz',
        Baz => 'qux',
    );

    my %expected = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );

    is_deeply \%header, \%expected, 'set() multiple elements';
};

subtest 'delete()' => sub {
    %header = (
        -foo => 'bar',
        -bar => 'baz',
    );

    is_deeply [ $header->delete('Foo', 'Bar') ], [ 'bar', 'baz' ];
    is_deeply \%header, {};

    %header = (
        -foo => 'bar',
        -bar => 'baz',
    );

    ok $header->delete('Foo', 'Bar') eq 'baz';
    is_deeply \%header, {};
};

subtest 'as_hashref()' => sub {
    my $got = $header->as_hashref;
    ok ref $got eq 'HASH';
    #ok tied %{ $got } eq $header;

    %header = ();
    $header->{Foo} = 'bar';
    is_deeply \%header, { -foo => 'bar' }, 'store';

    %header = ( -foo => 'bar' );
    is $header->{Foo}, 'bar', 'fetch';
    is $header->{Bar}, undef;

    %header = ( -foo => 'bar' );
    ok exists $header->{Foo}, 'exists';
    ok !exists $header->{Bar};

    %header = ( -foo => 'bar' );
    is delete $header->{Foo}, 'bar';
    is_deeply \%header, {}, 'delete';

    %header = ( -foo => 'bar' );
    %{ $header } = ();
    is_deeply \%header, { -type => q{} }, 'clear';
};

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

subtest 'DESTROY()' => sub {
    plan skip_all => 'doesnt work';
    #my $h = $class->new;
    $header->DESTROY;
    ok !$header->as_hashref;
    ok !$header->header;
};

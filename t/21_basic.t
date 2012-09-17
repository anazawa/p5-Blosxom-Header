use strict;
use Blosxom::Header;
use Test::More tests => 13;
use Test::Warn;
use Test::Exception;

subtest 'instance() throws an execption' => sub {
    my $expected = qr{^Blosxom::Header hasn't been initialized yet};
    throws_ok { Blosxom::Header->instance } $expected;
};

# initialize
my %header;
$blosxom::header = \%header;

my $header = Blosxom::Header->instance;
ok $header->isa( 'Blosxom::Header' );
can_ok $header, qw(
    clear delete exists field_names get set
    as_hashref is_empty flatten
    content_type type charset
    p3p_tags push_p3p_tags
    last_modified date expires
    attachment charset nph status target
);

# exists()
%header = ( -foo => 'bar' );
ok $header->exists( 'Foo' ), 'should return true';
ok !$header->exists( 'Bar' ), 'should return false';

# get()
%header = ( -foo => 'bar', -bar => 'baz' );
my @got = $header->get( 'Foo', 'Bar' );
my @expected = qw( bar baz );
is_deeply \@got, \@expected;

# clear()
%header = ( -foo => 'bar' );
$header->clear;
is_deeply \%header, { -type => q{} }, 'should be empty';

subtest 'set()' => sub {
    %header = ();

    my $expected = qr{^Odd number of elements passed to set\(\)};
    throws_ok { $header->set( 'Foo' ) } $expected;

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
        -baz => 'qux',
    );
    my @deleted = $header->delete( qw/foo bar/ );
    is_deeply \@deleted, [ 'bar', 'baz' ], 'delete() multiple elements';
    is_deeply \%header, { -baz => 'qux' };

    %header = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );
    is $header->delete(qw/foo bar baz/), 'qux';
    is_deeply \%header, {};
};

subtest 'each()' => sub {
    %header = ( -foo => 'bar' );
    my @got;
    $header->each( sub { push @got, @_ } );
    my @expected = (
        'Foo'          => 'bar',
        'Content-Type' => 'text/html; charset=ISO-8859-1',
    );
    is_deeply \@got, \@expected;
};

subtest 'is_empty()' => sub {
    %header = ();
    ok !$header->is_empty;
    %header = ( -type => q{} );
    ok $header->is_empty;
};

subtest 'flatten()' => sub {
    %header = (
        -status         => '304 Not Modified',
        -content_length => 12345,
    );

    my @expected = (
        'Status',         '304 Not Modified',
        'Content-length', '12345',
        'Content-Type',   'text/html; charset=ISO-8859-1',
    );

    is_deeply [ $header->flatten ], \@expected;
};

subtest 'as_hashref()' => sub {
    my $got = $header->as_hashref;
    ok ref $got eq 'HASH';

    ok my $tied = tied( %{ $got } );
    ok $tied eq $header;

    %header = ();
    $header->{Foo} = 'bar';
    is_deeply \%header, { -foo => 'bar' }, 'overload';

    ok exists $header->{Foo};
    ok !exists $header->{Bar};

    is delete $header->{Foo}, 'bar';
    is_deeply \%header, {};

    untie %{ $header->as_hashref };
    ok !$header->as_hashref, 'untie';
};

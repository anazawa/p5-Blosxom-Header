use strict;
use Blosxom::Header;
use Test::More tests => 17;
use Test::Warn;
use Test::Exception;

my $class = 'Blosxom::Header';

ok $class->isa( 'Blosxom::Header' );
ok $class->isa( 'Blosxom::Header::Entity' );
ok $class->isa( 'Blosxom::Header::Adapter' );

can_ok $class, qw(
    instance has_instance new
    clear delete exists get set is_empty
    dump as_hashref
    each flatten
    content_type type charset
    last_modified date
    status 
);

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
    %header = ();
    is $header->delete('Foo'), undef;

    %header = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );

    my @got = $header->delete(qw/Foo Bar/);

    is_deeply \@got, [ 'bar', 'baz' ], 'delete() multiple elements';
    is_deeply \%header, { -baz => 'qux' };

    %header = (
        -foo => 'bar',
        -bar => 'baz',
        -baz => 'qux',
    );

    my $got = $header->delete(qw/Foo Bar Baz/);

    ok $got eq 'qux';
    is_deeply \%header, {};
};

subtest 'each()' => sub {
    my $expected = qr{^Must provide a code reference to each\(\)};
    throws_ok { $header->each } $expected;

    %header = (
        -status         => '304 Not Modified',
        -content_length => 12345,
    );

    my @got;
    $header->each(sub {
        my ( $field, $value ) = @_;
        push @got, $field, $value;
    });

    my @expected = (
        'Status',         '304 Not Modified',
        'Content-length', '12345',
        'Content-Type',   'text/html; charset=ISO-8859-1',
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

    my @got = $header->flatten;

    my @expected = (
        'Status',         '304 Not Modified',
        'Content-length', '12345',
        'Content-Type',   'text/html; charset=ISO-8859-1',
    );

    is_deeply \@got, \@expected;
};

subtest 'as_hashref()' => sub {
    my $got = $header->as_hashref;
    ok ref $got eq 'HASH';
    ok tied %{ $got } eq $header;

    %header = ();
    $header->{Foo} = 'bar';
    is_deeply \%header, { -foo => 'bar' }, 'overload';

    ok exists $header->{Foo};
    ok !exists $header->{Bar};

    is delete $header->{Foo}, 'bar';
    is_deeply \%header, {};
};

subtest 'dump()' => sub {
    %header = ( -type => 'text/plain' );

    my $got = eval $header->dump;

    my %expected = (
        'adapter' => {
            'Content-Type' => 'text/plain; charset=ISO-8859-1',
        },
        'adaptee' => {
            '-type' => 'text/plain',
        },
    );

    is_deeply $got, \%expected;
};

subtest 'DESTROY()' => sub {
    $header->DESTROY;
    ok !$header->as_hashref;
    ok !$header->header;
};

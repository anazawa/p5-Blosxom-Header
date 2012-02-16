use strict;
use Test::More;
use Blosxom::Header;
use Blosxom::Header::Prototype;

{
    my @tests = (
        [ 'foo'      => 'foo'     ],
        [ 'Foo'      => 'foo'     ],
        [ '-foo'     => 'foo'     ],
        [ '-Foo'     => 'foo'     ],
        [ 'foo_bar'  => 'foo-bar' ],
        [ 'Foo_Bar'  => 'foo-bar' ],
        [ '-foo_bar' => 'foo-bar' ],
        [ '-Foo_Bar' => 'foo-bar' ],
    );

    for my $test ( @tests ) {
        my ( $input, $output ) = @{ $test };
        is Blosxom::Header::_lc( $input ), $output;
    }
}

{
    my $counter = 0;
    my %method  = ( count => sub { $counter++ } );
    my $object  = Blosxom::Header::Prototype->new( %method );
    isa_ok $object, 'Blosxom::Header::Prototype';
    can_ok $object, qw(count);

    $object->count;

    is $counter, 1;
    ok !$object->can('foo');
}

{
    my %method1 = ( foo => sub { 'bar' } );
    my $object1 = Blosxom::Header::Prototype->new( %method1 );
    is $object1->foo(), 'bar';

    my %method2 = ( bar => sub { 'baz' } );
    my $object2 = Blosxom::Header::Prototype->new( %method2 );
    is $object2->bar(), 'baz';

    ok !$object1->can('bar');
    ok !$object2->can('foo');
}

{
    my %method = ( foo => sub { 'bar' }, bar => 'baz' );
    my $object = Blosxom::Header::Prototype->new( %method );
    is $object->foo(), 'bar';
    ok !$object->can('bar');
}

done_testing;

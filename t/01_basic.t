use strict;
use Test::More;
use Blosxom::Header;
use Blosxom::Header::Object;

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
    my $counter     = 0;
    my %counter     = ( count => sub { $counter++ } );
    my $counter_obj = bless \%counter, 'Blosxom::Header::Object';

    isa_ok $counter_obj, 'Blosxom::Header::Object';
    can_ok $counter_obj, 'count';

    $counter_obj->count;

    is $counter, 1, 'method call works';
    ok $counter_obj->can('count');
    ok !$counter_obj->can('foo');
}

done_testing;

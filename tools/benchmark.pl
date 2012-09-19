use strict;
use warnings;
use Benchmark qw/cmpthese/;
use Blosxom::Header qw(
    header_set    header_get  header_exists
    header_delete header_iter
);

$blosxom::header = {};
my $header = Blosxom::Header->instance;

cmpthese(-1, {
    STORE      => sub { $header->STORE( Foo => 'bar' ) },
    overload   => sub { $header->{Foo} = 'bar'         },
    set        => sub { $header->set( Foo => 'bar' )   },
    header_set => sub { header_set( Foo => 'bar' )     },
});

cmpthese(-1, {
    FETCH      => sub { my $value = $header->FETCH( 'Foo' ) },
    overload   => sub { my $value = $header->{Foo}          },
    get        => sub { my $value = $header->get( 'Foo' )   },
    header_get => sub { my $value = header_get( 'Foo' )     },
});

cmpthese(-1, {
    EXISTS        => sub { my $bool = $header->EXISTS( 'Foo' ) },
    overload      => sub { my $bool = exists $header->{Foo}    },
    exists        => sub { my $bool = $header->exists( 'Foo' ) },
    header_exists => sub { my $bool = header_exists( 'Foo' )   },
});

cmpthese(-1, {
    DELETE => sub {
        %{ $blosxom::header } = ( -foo => 'bar' );
        $header->DELETE( 'Foo' );
    },
    overload => sub {
        %{ $blosxom::header } = ( -foo => 'bar' );
        delete $header->{Foo};
    },
    delete => sub {
        %{ $blosxom::header } = ( -foo => 'bar' );
        $header->delete( 'Foo' );
    },
    header_delete => sub {
        %{ $blosxom::header } = ( -foo => 'bar' );
        header_delete( 'Foo' );
    },
});

cmpthese(-1, {
    CLEAR    => sub { $header->CLEAR    },
    overload => sub { %{ $header } = () },
    clear    => sub { $header->clear    },
});

$header->set(
    Foo => 'bar',
    Bar => 'baz',
    Baz => 'qux',
);

cmpthese(-1, {
    each => sub {
        my @headers;
        $header->each(sub {
            my ( $field, $value ) = @_;
            push @headers, $field, $value;
        });
    },
    header_iter => sub {
        my @headers;
        header_iter sub {
            my ( $field, $value ) = @_;
            push @headers, $field, $value;
        };
    },
});

cmpthese(-1, {
    is_empty => sub { my $bool = $header->is_empty   },
    SCALAR   => sub { my $bool = not $header->SCALAR },
    overload => sub { my $bool = not %{ $header }    },
});

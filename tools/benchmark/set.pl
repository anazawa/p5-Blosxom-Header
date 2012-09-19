use strict;
use warnings;
use Benchmark qw/cmpthese/;
use Blosxom::Header::Entity;

my $header = Blosxom::Header::Entity->new;
my $now    = time;

cmpthese(-1, {
    'Content-Type' => sub {
        $header->STORE( 'Content-Type' => 'text/plain; charset=utf-8' );
    },
    'Content-Disposition' => sub {
        $header->STORE( 'Content-Disposition' => 'inline' );
    },
    'Date' => sub {
        $header->STORE( 'Date' => 'Thu, 25 Apr 1999 00:40:33 GMT' );
    },
    'Foo' => sub {
        $header->STORE( 'Foo' => 'bar' );
    },
});

cmpthese(-1, {
    content_type => sub {
        $header->content_type( 'text/plain; charset=utf-8' );
    },
    attachment => sub {
        $header->attachment( 'genome.jpg' );
    },
    expires => sub {
        $header->expires( $now );
    },
    last_modified => sub {
        $header->last_modified( $now );
    },
    status => sub {
        $header->status( 304 );
    },
    target => sub {
        $header->target( 'ResultsWindow' );
    },
    nph => sub {
        $header->nph( 1 );
    },
    p3p_tags => sub {
        $header->p3p_tags( 'CAO DSP LAW CURa' );
    },
});

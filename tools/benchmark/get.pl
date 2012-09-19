use strict;
use warnings;
use Benchmark qw/cmpthese/;
use Blosxom::Header::Entity;

my $header = Blosxom::Header::Entity->new({
    -type       => 'text/plain',
    -charset    => 'utf-8',
    -attachment => 'genome.jpg',
    -p3p        => [qw/CAO DSP LAW CURa/],
    -target     => 'ResultsWindow',
    -foo        => 'bar',
    -expires    => '+3M',
    -nph        => 1,
    -status     => '304 Not Modified',
    -cookie     => 'ID=123456; path=/',
});

$header->last_modified( time );

cmpthese(-1, {
    'Content-Type' => sub {
        my $value = $header->FETCH('Content-Type');
    },
    'Content-Disposition' => sub {
        my $value = $header->FETCH('Content-Disposition');
    },
    'P3P' => sub {
        my $value = $header->FETCH('P3P');
    },
    'Window-Target' => sub {
        my $value = $header->FETCH('Window-Target');
    },
    'Foo' => sub {
        my $value = $header->FETCH('Foo');
    },
    'Date' => sub {
        my $value = $header->FETCH('Date');
    },
    'Expires' => sub {
        my $value = $header->FETCH('Expires');
    },
    'Set-Cookie' => sub {
        my $value = $header->FETCH('Set-Cookie');
    },
});

cmpthese(-1, {
    charset       => sub { my $v = $header->charset       },
    date          => sub { my $v = $header->date          },
    expires       => sub { my $v = $header->expires       },
    attachment    => sub { my $v = $header->attachment    },
    content_type  => sub { my @v = $header->content_type  },
    nph           => sub { my $v = $header->nph           },
    p3p_tags      => sub { my @v = $header->p3p_tags      },
    status        => sub { my $v = $header->status        },
    target        => sub { my $v = $header->target        },
    last_modified => sub { my $v = $header->last_modified },
});

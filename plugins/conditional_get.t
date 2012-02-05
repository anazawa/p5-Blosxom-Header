use strict;
use FindBin;
use Test::More;

{
    package blosxom;
    our $static_entries = 0;
    our $header = {};
    our $output;
}

my $plugin = 'conditional_get';

require_ok "$FindBin::Bin/$plugin";
can_ok $plugin, qw/start last/;
ok $plugin->start();

my @tests = (
    {
        headers  => { '-type' => 'text/html' },
        env      => { REQUEST_METHOD => 'GET' },
        output   => 'abcdj',
        expected => {
            header => { '-type' => 'text/html' },
            output => 'abcdj',
        }
    },
    {
        headers => {
            '-type' => 'text/html',
            '-etag' => 'Foo', 
        },
        env => {
            REQUEST_METHOD     => 'GET',
            HTTP_IF_NONE_MATCH => 'Foo',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-etag'   => 'Foo',
                'Status' => '304 Not Modified',
            },
            output => q{},
        }
    },
    {
        headers => {
            '-type'          => 'text/html',
            '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
        },
        env => {
            REQUEST_METHOD         => 'GET',
            HTTP_IF_MODIFIED_SINCE => 'Wed, 23 Sep 2009 13:36:33 GMT',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
                'Status'        => '304 Not Modified',
            },
            output => q{},
        }
    },
    {
        headers => {
            '-type'          => 'text/html',
            '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
        },
        env => {
            REQUEST_METHOD         => 'GET',
            HTTP_IF_MODIFIED_SINCE => 'Wed, 23 Sep 2009 13:36:32 GMT',
        },
        output => 'abcdj',
        expected => {
            header => {
                 '-type'          => 'text/html',
                 '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
            },
            output => 'abcdj',
        }
    },
    {
        headers => {
            '-type'          => 'text/html',
            '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT'
        },
        env => {
            'REQUEST_METHOD' => 'GET',
            'HTTP_IF_MODIFIED_SINCE'
                => 'Wed, 23 Sep 2009 13:36:33 GMT; length=2',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-last-modified' => 'Wed, 23 Sep 2009 13:36:33 GMT',
                'Status'        => '304 Not Modified'
            },
            output => q{},
        }
    },
    {
        headers => {
            '-type' => 'text/html',
            '-etag' => 'Foo', 
        },
        env => {
            REQUEST_METHOD     => 'POST',
            HTTP_IF_NONE_MATCH => 'Foo',
        },
        output => 'abcdj',
        expected => {
            header => {
                '-type' => 'text/html',
                '-etag' => 'Foo',
            },
            output => 'abcdj',
        }
    },
);

for my $block (@tests) {
    %$blosxom::header = %{$block->{headers}};
    $blosxom::output = $block->{output};
    local %ENV = %{$block->{env}};

    $plugin->last();

    is_deeply $blosxom::header, $block->{expected}{header};
    is $blosxom::output, $block->{expected}{output};
}

done_testing;

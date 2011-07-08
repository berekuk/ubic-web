#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use Test::More;

use Plack::Test;
use Ubic::Web;
use HTTP::Request::Common;

test_psgi
    app => Ubic::Web->to_psgi_app,
    client => sub {
        my $cb = shift;
        {
            my $res = $cb->(GET '/ping');
            is $res->content, 'ok';
        }
        {
            my $res = $cb->(GET '/api/status/ubic');
            is $res->content, 'Not implemented.';
        }
        {
            my $res = $cb->(GET '/');
            is $res->code, 200;
            like $res->content, qr/subservices/;
        }
    },
;

done_testing;

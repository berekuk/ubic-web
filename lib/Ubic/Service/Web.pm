package Ubic::Service::Web;

use strict;
use warnings;

use LWP::UserAgent;
use parent qw(Ubic::Service::Plack);
use Starman; # just for the sake of dependency detection
use Ubic::Result qw(result);

sub new {
    my ($class, %options) = @_;

    my $server_options = delete $options{server_args};
    $server_options ||= {};
    return $class->SUPER::new(
        server => "Starman",
        server_args => {
            port => 12346,
            workers => 1,
            %$server_options,
        },
        app      => '/usr/bin/ubic-web',
        app_name => 'ubic-web',
        port => 12346,
        %options,
    );
}

sub status_impl {
    my $self = shift;
    my $response = LWP::UserAgent->new(timeout => 3)->get("http://localhost:".$self->port."/status");
    my $result = $self->SUPER::status_impl;
    return $result if result($result) ne 'running';
    if ($response->is_success and $response->content eq 'Ok.') {
        return $result;
    }
    return 'broken';
}

1;

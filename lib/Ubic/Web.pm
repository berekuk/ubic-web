use Web::Simple 'Ubic::Web';

{
  package Ubic::Web;

# ABSTRACT: psgi app for viewing ubic statuses

  use Ubic;
  use Data::Dumper;
  use JSON::XS;

  sub default_config {(
    exclude => [qw/service.a service.b.*/],
    # --or--
    include => [qw/service.a.*/],
    servers => [{ 
        host => '127.0.0.1:3456',
        exclude => [qw/service.a service.b.*/],
        include => [qw/service.a.*/],
    }],
  )};

  sub _status_tree {
    my $self = shift;
    my ($service, $result) = @_;
    my $result = {};
    $result->{service} = $service->name if $service;
    $service ||= Ubic->root_service;

    if ($service->isa('Ubic::Multiservice')) {
      for my $subservice ($service->services) {
        push @{$result->{subservices}}, $self->_status_tree($subservice);
      }
    }
    else {
      my $enabled = Ubic->is_enabled($service->full_name);
      if ($enabled) {
        $result->{enabled} = 1;
        my $status = Ubic->cached_status($service->full_name);
        $result->{status} = { status => $status->status, as_string => "$status" };
      }
      else {
        $result->{enabled} = 0;
      }
    }
    return $result;
  }

  sub dispatch_request {
    sub (/ping ) {
      [ 200, [ 'Content-type', 'text/plain' ], [ "ok" ] ]
    },
    sub (/) {
      my $self = shift;
      redispatch_to '/api/status/';
    },
    sub (/api/status/...) {
      sub (/) {
        my $self = shift;
        my $statuses = $self->_status_tree;
        my $json = JSON::XS->new->ascii->pretty->encode($statuses);
        [ 200, [ 'Content-type', 'text/plain' ], [ $json ] ]
      },
      #multiservice subset i.e
      # /status/web, /status/web/jobs
      sub (/**) {
        [ 200, [ 'Content-type', 'text/plain' ], [ "Not implemented." ] ]
      },
    },
  };
}

Ubic::Web->run_if_script;

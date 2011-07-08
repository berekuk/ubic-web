use Web::Simple 'Ubic::Web';


{
  package Ubic::Web;

# ABSTRACT: psgi app for viewing ubic statuses

  use Ubic;
  use Data::Dumper;

  sub _traverse {
    my $self = shift;
    my ($service, $callback) = @_;
    if ($service->isa('Ubic::Multiservice')) {
      for my $subservice ($service->services) {
          $self->_traverse($subservice, $callback);
      }
    }
    else {
      $callback->($service);
    }
  }

  sub _all_statuses {
    my $self = shift;
    my $root = Ubic->root_service;

    my $result = {};
    $self->_traverse($root, sub {
      my $service = shift;
      $result->{ $service->full_name } = Ubic->cached_status($service->full_name);
    });

    return $result;
    # all services will be in plain hashref
    # maybe it's not the best solution, but it you want the tree, just traverse it yourself :)
  }

  sub dispatch_request {
    sub (/status ) {
      [ 200, [ 'Content-type', 'text/plain' ], [ "Ok." ] ]
    },
    sub (/) {
      my $self = shift;
      my $statuses = $self->_all_statuses;
      [ 200, [ 'Content-type', 'text/plain' ], [ Dumper($statuses) ] ]
    },
  };
}

Ubic::Web->run_if_script;

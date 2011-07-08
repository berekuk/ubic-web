use Web::Simple 'Ubic::Web';
use JSON::XS;

{
  package Ubic::Web;
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
  sub dispatch_request {
    sub (/status ) {
      sub (/) {
        [ 200, [ 'Content-type', 'text/plain' ], [ "Ok." ] ]
      },
      sub (/**) {
        #multiservice subset i.e
        # /status/web, /status/web/jobs
        [ 200, [ 'Content-type', 'text/plain' ], [ "Ok." ] ]
      },
      
    }
  };
}
 
Ubic::Web->run_if_script;
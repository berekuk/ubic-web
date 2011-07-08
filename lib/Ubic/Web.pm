use Web::Simple 'Ubic::Web';
 
{
  package Ubic::Web;
  sub dispatch_request {
    sub (/status ) {
      [ 200, [ 'Content-type', 'text/plain' ], [ "Ok." ] ]
    }
  }
}
 
Ubic::Web->run_if_script;
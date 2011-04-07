package Log::Dump::Test::Functions::Basic;

use strict;
use warnings;
use Test::Classy::Base;
use Log::Dump::Functions;

__PACKAGE__->mk_classdata('capture');

sub initialize {
  my $class = shift;
  eval { require IO::Capture::Stderr };
  $class->skip_this_class('this test requires IO::Capture') if $@;

  $class->capture( IO::Capture::Stderr->new );
}

sub plain_usage : Tests(2) {
  my $class = shift;

  my $capture = $class->capture;

  $capture->start;
  log( debug => 'message' );
  $capture->stop;
  my $captured = join "\n", $capture->read;

  like $captured => qr/\[debug\] message/,
    $class->message('captured');
  unlike $captured => qr{Log.Dump.Functions},
    $class->message('not from Log::Dump::Functions');
}

sub error : Tests(2) {
  my $class = shift;

  my $capture = $class->capture;

  $capture->start;
  log( error => 'message' );
  $capture->stop;
  my $captured = join "\n", $capture->read;

  like $captured => qr/\[error\] message/,
    $class->message('captured');
  unlike $captured => qr{Log.Dump.Functions},
    $class->message('not from Log::Dump::Functions');
}

sub fatal : Tests(2) {
  my $class = shift;

  eval { log( fatal => 'message' ) };

  like $@ => qr/\[fatal\] message/,
    $class->message('captured');
  unlike $@ => qr{Log.Dump.Functions},
    $class->message('not from Log::Dump::Functions');
}

1;

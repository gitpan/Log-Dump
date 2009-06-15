package Log::Dump::Test::Singleton::Basic;

use strict;
use warnings;
use Test::Classy::Base;
use Log::Dump::Test::SingletonUserA;
use Log::Dump::Test::SingletonUserB;

sub log_class_has : Tests(5) {
  my $class = shift;

  foreach my $method (qw( log logger logfilter logfile logcolor )) {
    ok(Log::Dump::Test::SingletonLog->can($method),
       $class->message($method));
  }
}

sub log_object_has : Tests(5) {
  my $class = shift;

  my $object = Log::Dump::Test::SingletonLog->new;

  foreach my $method (qw( log logger logfilter logfile logcolor )) {
    ok($object->can($method),
       $class->message($method));
  }
}

sub user_class_has : Tests(5) {
  my $class = shift;

  foreach my $method (qw( log logger logfilter logfile logcolor )) {
    ok(Log::Dump::Test::SingletonUserA->can($method),
       $class->message($method));
  }
}

sub user_object_has : Tests(5) {
  my $class = shift;

  my $object = Log::Dump::Test::SingletonUserA->new;

  foreach my $method (qw( log logger logfilter logfile logcolor )) {
    ok($object->can($method),
       $class->message($method));
  }
}

sub class_logger : Tests(6) {
  my $class = shift;

  ok(!defined Log::Dump::Test::SingletonUserA->logger,
     $class->message('logger for user A is not defined'));

  ok(!defined Log::Dump::Test::SingletonUserB->logger,
     $class->message('logger for user A is not defined'));

  ok(!defined Log::Dump::Singleton->logger,
     $class->message('base logger is not defined'));

  Log::Dump::Test::SingletonUserA->logger(0);

  ok(defined Log::Dump::Test::SingletonUserB->logger,
     $class->message('logger for user B is also defined'));

  ok(defined Log::Dump::Test::SingletonLog->logger,
     $class->message('singleton logger is also defined'));

  ok(!defined Log::Dump::Singleton->logger,
     $class->message('still, base logger is not defined'));
}

sub object_logger : Tests(7) {
  my $class = shift;

  # singleton logger is actually a class logger
  Log::Dump::Test::SingletonUserA->logger(undef);
  Log::Dump::Test::SingletonUserB->logger(undef);

  my $user_a = Log::Dump::Test::SingletonUserA->new;
  my $user_b = Log::Dump::Test::SingletonUserB->new;

  ok(!defined $user_a->logger,
     $class->message('logger for user A is not defined'));

  ok(!defined $user_b->logger,
     $class->message('logger for user A is not defined'));

  ok(!defined Log::Dump::Test::SingletonLog->logger,
     $class->message('singleton logger is not defined'));

  ok(!defined Log::Dump::Singleton->logger,
     $class->message('base logger is not defined'));

  $user_a->logger(0);

  ok(defined $user_b->logger,
     $class->message('logger for user B is also defined'));

  ok(defined Log::Dump::Test::SingletonLog->logger,
     $class->message('singleton logger is also defined'));

  ok(!defined Log::Dump::Singleton->logger,
     $class->message('still, base logger is not defined'));
}

1;

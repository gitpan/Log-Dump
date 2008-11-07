package Log::Dump;

use strict;
use warnings;
use Sub::Install qw( install_sub );
use Scalar::Util qw( blessed );

our $VERSION = '0.01';

my $caller = caller;

install_sub({
  as   => 'logger',
  into => $caller,
  code => sub {
    my $self = shift;

    my $logger = $_[0];
       $logger = undef if $logger and $logger !~ /^[A-Z]/;
    if ( blessed $self ) {
      @_ ? $self->{_logger} = $logger : $self->{_logger};
    }
    else {
      no strict 'refs';
      @_ ? ${"$self\::_logger"} = $logger : ${"$self\::_logger"};
    }
  },
});

install_sub({
  as   => 'logfilter',
  into => $caller,
  code => sub {
    my $self = shift;

    my $filter = @_ && $_[0] ? [@_] : undef;

    if ( blessed $self ) {
      @_ ? $self->{_logfilter} = $filter : $self->{_logfilter};
    }
    else {
      no strict 'refs';
      @_ ? ${"$self\::_logfilter"} = $filter : ${"$self\::_logfilter"};
    }
  },
});

install_sub({
  as   => 'logfile',
  into => $caller,
  code => sub {
    my $self = shift;

    if ( @_ && $_[0] ) {
      push @_, 'w' if @_ == 1;
      require IO::File;
      my $fh = IO::File->new(@_) or $self->log( fatal => $! );
      if ( blessed $self ) {
        $self->{_logfile} = $fh;
      }
      else {
        no strict 'refs';
        ${"$self\::_logfile"} = $fh;
      }
    }
    elsif ( @_ && !$_[0] ) {
      if ( blessed $self ) {
        $self->{_logfile}->close if $self->{_logfile};
        $self->{_logfile} = undef;
      }
      else {
        no strict 'refs';
        ${"$self\::_logfile"}->close if ${"$self\::_logfile"};
        ${"$self\::_logfile"} = undef;
      }
    }
    else {
      if ( blessed $self ) {
        $self->{_logfile};
      }
      else {
        no strict 'refs';
        ${"$self\::_logfile"};
      }
    }
  },
});

install_sub({
  as   => 'log',
  into => $caller,
  code => sub {
    my $self = shift;

    my $logger = $self->logger;

    if ( defined $logger and !$logger ) {
      return;
    }
    elsif ( $logger and $logger->can('log') ) {
      $logger->log(@_);
    }
    else {
      my $label = shift;

      return if $self->logfilter and !grep { $label eq $_ } @{ $self->logfilter };

      require Data::Dump;
      my $msg = join '', map { ref $_ ? Data::Dump::dump($_) : $_ } @_;

      if ( $label eq 'fatal' ) {
        require Carp;
        Carp::croak "[$label] $msg";
      }
      elsif ( $label eq 'error' or $label eq 'warn' ) {
        require Carp;
        Carp::carp "[$label] $msg";
        $self->logfile->print(Carp::shortmess("[$label] $msg"), "\n") if $self->logfile;
      }
      else {
        print STDERR "[$label] $msg\n";
        $self->logfile->print("[$label] $msg\n") if $self->logfile;
      }
    }
  },
});

1;

__END__

=head1 NAME

Log::Dump - simple logger mainly for debugging

=head1 SYNOPSIS

    use Log::Dump; # installs 'log' and other methods

    # class log
    __PACKAGE__->log( error => 'foo' );

    # object log
    sub some_method {
      my $self = shift;

      # you can pass multiple messages (will be concatenated)
      # and objects (will be dumped via L<Data::Dump>).
      $self->log( info => 'my self is ', $self );
    }

    # you can control which log should be shown by labels.
    sub broken_method {
      my $self = shift;

      $self->logfilter('broken_only');
      $self->log( broken_only => 'shown' );
      $self->log( debug       => 'not shown' );
    }

    # you can log to a file
    __PACKAGE__->logfile('log.txt');
    __PACKAGE__->log( file => 'will be saved' );
    __PACKAGE__->logfile('');  # to close

    # you can turn off the logging; set to true to turn on.
    __PACKAGE__->logger(0);

    # or you can use better loggers (if they have a 'log' method)
    __PACKAGE__->logger( Log::Dispatch->new );

=head1 DESCRIPTION

L<Log::Dump> is a simple logger mix-in mainly for debugging. This installs four methods into a caller (the class that C<use>d L<Log::Dump>) via L<Sub::Install>. The point is you don't need to load extra dumper modules or you don't need to concatenate messages. Just log things and they will be dumped (and concatenated if necessary) to stderr, and to a file if you prefer. Also, you can use these logging methods as class methods or object methods (though usually you don't want to mix them, especially when you're doing something special).

=head1 METHODS

=head2 log

logs things to stderr. The first argument (other than class/object) is considered as a label for the messages, and will be wrapped with square blackets. Objects in the messages will be dumped through L<Data::Dump>, and multiple messages will be concatenated. And usually line feed/carriage return will be appended.

The C<fatal> label is special: if you log things with this label, the logger croaks the messages (and usually the program will die).

Also, if you log things with C<error> or C<warn> labels, the logger carps the messages (with a line number and a file name).

Other labels have no special meaning for the logger, but as you can filter some of the logs with these labels, try using meaningful ones for you.

Note that these special labels doesn't work with custom loggers. Actually, you can pass anything to C<log> method to conform to your logger's requirement.

=head2 logger

turns on/off the logger if you set this to true/false (preferably, 1/0 to avoid confusion). And if you set a class name (or an object) that provides C<log> method, it will be used while logging.

=head2 logfilter

If you specify some labels through this, only logs with those labels will be shown. Set a false value to disable this filtering.

=head2 logfile

If you want to log to a file, set a file name, and an optional open mode for L<IO::File> (C<w> for write by default). When you set a false value, the opened file will be closed. Note that this doesn't disable logging to stderr. Logs will be dumped both to stderr and to a file while the file is open.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

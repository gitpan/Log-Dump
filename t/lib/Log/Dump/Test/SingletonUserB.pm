package Log::Dump::Test::SingletonUserB;

use strict;
use warnings;
use Log::Dump::Test::SingletonLog;

sub new { bless {}, shift }

1;

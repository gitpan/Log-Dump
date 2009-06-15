package Log::Dump::Test::SingletonLog;

use strict;
use warnings;
use Log::Dump::Singleton;

sub new { bless {}, shift }

1;

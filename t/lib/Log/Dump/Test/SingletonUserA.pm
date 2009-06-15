package Log::Dump::Test::SingletonUserA;

use strict;
use warnings;
use Log::Dump::Test::SingletonLog;

sub new { bless {}, shift }

1;

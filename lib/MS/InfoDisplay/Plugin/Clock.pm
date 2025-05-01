package MS::InfoDisplay::Plugin::Clock;

use strictures 2;
use DateTime;

sub messages_count {
    return 1;
}

sub run {
    return DateTime->new->hms;
#    return scalar localtime;
}

1;

package MS::InfoDisplay::Plugin::Clock;

use feature 'signatures';
use strictures 2;
use DateTime;
use DateTime::Format::Baby;
use DateTime::Format::Human;
use DateTime::Format::GeekTime;
use DateTime::Format::TauStation;
use DateTime::Calendar::Discordian;

# Things where we can just do a ->new, ->format_datetime and get something nice enough.
my @simple_formats = (
    'DateTime::Format::Baby',
    'DateTime::Format::Human',
    # Just not very fun
    # 'DateTime::Format::GeekTime',
    # Broken?
    # 'DateTime::Format::TauStation'
    # 'DateTime::Format::Japanese'
);

# Basically a wishlist of things that I'd like to do but require a little bit of specific effort.
my @complex_formats = (
    'DateTime::Format::CLDR'
);

sub messages_count {
    return @simple_formats + 1;
}

sub run ($self, $n, $screensize) {
    my $now = DateTime->now;

    if ($n < @simple_formats) {
        return $simple_formats[$n]->new->format_datetime($now);
    }
    $n -= @simple_formats;

    if ($n == 0) {
        my $cal = DateTime::Calendar::Discordian->from_object(object => $now);
        # Why doesn't my %. work?
        #return $cal->strftime("%A, %{%e of %B%} %Y YOLD\n%H\n%.");
        return $cal->strftime("%A, %{%e of %B%} %Y YOLD\n%H");
    }
    $n--;

}

1;

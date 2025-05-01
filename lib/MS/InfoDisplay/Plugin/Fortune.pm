package MS::InfoDisplay::Plugin::Fortune;

use strictures 2;
use 5.36.0;

my @messages = 
    (
        "Leave the space a little tidier than you found it",
        "Use a mug and wash it up, or buy a paper cup",
        "Measure twice, cut once",
        "There is a label printer on top of the grey cabinet upstairs",
        "Let us know when we get low on something, not just out of it",
        "PLA is a good general-purpose 3d printer filiment",
        "PETG is harder to print with then PLA, but stronger and better at handling heat",
        "Have a wander around, see what tools we have you didn't know about",
        "Aim to leave the space cleaner than when you started",
        "If it isn't for everybody's use, take it home or put it in your member's box",
        "Your members box should be labled on both of the long sides",
    );

sub messages_count {
    return 0+@messages;
}

sub run {
    my ($self, $n) = @_;
    return $messages[$n];
}

1;

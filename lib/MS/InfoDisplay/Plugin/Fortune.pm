package MS::InfoDisplay::Plugin::Fortune;

use strictures 2;
use v5.28;

my @messages = (
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
        "Make all the things!",
        "Why not more penguins?",
        $img->read(file => $penguin1)   
        or die()"Cannot read $filename: ", $img->errstr),
        "Your member box should have your name on it, easily legable, on both long sides",
        "You can buy your own member box, 32L storage box from The Range",
        "Remember to turn off the lights as you leave",
        "Using a little of a consumable?  Go for it.  Using a lot?  Buy a job lot and give us the spare.",
        "Rule 0: Do not be on fire.",
        "Emergency exits are this door, or the kitchen.",
        "In case of a fire, there are fire extinguishers around.  In the case of a *real* fire, get out and call 999.  Worry about fallout *after* everyone is safe.",
        "If the bin is full, it is your turn to take it out.  The skips are in the right hand road-side corner as you exit the building.",
        "Found something broken? Label it and let someone know.",
        "Generally useful jigs should be labled with what machine they are for and what they do",
        "Vaccuum/sweep up the floor if there's sawdust, swarf, or general ditritus.  It travels!",
        "If in doubt, give it a nice label",
        "If it's not away, figure out where away is an put it there.  If it wasn't obvious, label to make it more obvious.",
        "Many of us like answering questions.  Some of us might even know the answers!",
        "If something is broken, tell the relevant Telegram group, and give it a sign.",
        "Try to keep your criticism kind and actionable.  If you can't manage both, try for either.",
        "We’re all volunteers—pitch in when you can.",
        "Nobody is getting paid for this.  Even the directors are paying their dues.",
        "If the robot offers you tea, politely decline.",
        "Caution: Happy Fun Ball may suddenly accelerate to dangerous speeds. Happy Fun Ball contains a liquid core, which, if exposed due to rupture, should not be touched, inhaled, or looked at.",
        "If Happy Fun Ball begins to smoke, get away immediately. Seek shelter and cover head. ",
        "Do not taunt Happy Fun Ball.",
        "Share your projects! Inspiration is contagious.",
        "Let us know when things go right, not just when they go wrong",
        "If it’s cool and you made it here, show it off.  Send pictures to the pictures for social media telegram group if you don't mind us using them.",
        "There's a soda can bin in the kitchen",
    );

sub messages_count {
    return 0+@messages;
}

sub run {
    my ($self, $n) = @_;
    return $messages[$n];
}

1;

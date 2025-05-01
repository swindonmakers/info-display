package MS::InfoDisplay::Plugin::MNutSize;

use strictures 2;
use 5.36.0;

sub messages_count {
    return 1;
}

sub run {
    state $sizes = [
        [3, 5],
        [4, 7],
        [5, 8],
        [6, 10],
        [8, 13],
        [10, 16],
        [12, 18],
        [16, 24]
    ];

    my $size = $sizes->[rand @$sizes];

    return "For an M$size->[0] nut use a $size->[1] mm AF wrench";
}

1;

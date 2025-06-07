package MS::InfoDisplay::Plugin::Images;

use strictures 2;
use v5.28;
use Imager;
use Path::Class qw/dir/;

sub run {
    my ($self, $msg_num, $screensize) = @_;


    my @images = dir('./images')->children;
    my $file = $images[$msg_num];
    print "Found image: $file\n";
    my $imager = Imager->new(file => "$file");
    my $scaled = $imager->scaleX(pixels => $screensize->{x})->scaleY(pixels => $screensize->{y});
    return $scaled;
}

sub messages_count {
    my ($self) = @_;

    my $imgs = dir('./images');

    return scalar $imgs->children;
}

1;

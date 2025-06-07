package MS::InfoDisplay::Plugin::Images;

use strictures 2;
use v5.28;
use Imager;
use Path::Class qw/dir/;

sub run {
    my ($self, $msg_num, $screensize) = @_;

    my @images = dir("$ENV{INFODISPLAY_HOME}/images")->children;
    my $file = $images[0];
#    my $file = $images[$msg_num];
    print "Found image: $file\n";
    my $imager = Imager->new(file => "$file");
    $imager || print STDERR Imager->errstr . "\n";;
    if(!$imager) {
        return 'No image';
    }
    # Remove transparent border if any
    my $trimmed = $imager->trim();
    # Remove other transparent pixels
    my $noalpha = $trimmed->convert(preset => 'noalpha');
    my $scaled = $noalpha->scaleX(pixels => $screensize->{x})->scaleY(pixels => $screensize->{y});
    return $scaled;
}

sub messages_count {
    my ($self) = @_;

    return 1000;
    my $imgs = dir("$ENV{INFODISPLAY_HOME}/images");

    return scalar $imgs->children;
}

1;

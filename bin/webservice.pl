#!/usr/bin/perl

=head1 NAME

webservice.pl

=head1 DESCRIPTION

The main script, requires Perl to run, see INSTALL.md for installation.

To read this file nicely formatted, use B<perldoc webservice.pl>

To run: B<carton exec perl bin/webservice.pl daemon -m production -l http://*:5001>

=head1 THE CODE

=head2 Libraries

You can look these up on L<https://metacpan.org>

=cut

use v5.36;
use Mojolicious::Lite -signatures;
use Imager;
use Imager::Font::Wrap;
use Path::Class;
use Regexp::Common 'profanity';
use Data::Dumper;

use lib 'lib';
use MS::InfoDisplay;
use Data::Printer output => 'stderr';

=head2 Web endpoint /message

Answer GET requests to /message

L<Mojolicious::Lite> does all the heavy lifting here, we define some
code (a code reference) that is called when something fetches
L<http://whereever/message>.

=cut

my $screensize = { x => 3*64, y => 3*32 };
# my $screensize = { x => 96, y => 32 };
my $fontsize = 8; # 12

get '/message' => sub ($c) {
    # Look for all plugins:
    my $info_display = MS::InfoDisplay->new();
    my @plugins = $info_display->plugins();

    die "No plugins" if !@plugins;

    # Collect all possible messages
    # One key per message, track which plugin and its arguments in the values
    my %display_messages = ();
    my $max_random = 0;
    my @plugin_info;

    foreach my $plugin (@plugins) {
        $c->app->log->debug("Found plugin: $plugin");
        my $messages = $plugin->messages_count;

        push @plugin_info, {plugin => $plugin, count => $messages};

        $max_random += $messages;
    }

    die "No messages?" if $max_random == 0;

    say STDERR "max_random: $max_random";

    my $the_random = int rand $max_random;

    say STDERR "the_random: $the_random";

    my $plugin_info;
    for my $loop_plugin_info (@plugin_info) {
        # This is ugly as all fuck.
        $plugin_info = $loop_plugin_info;
        if ($the_random < $plugin_info->{count}) {
            last;
        }
        $the_random -= $plugin_info->{count};
    }

    p $plugin_info;

    my $message = $plugin_info->{plugin}->run($the_random);

    # If its not an Image, assume its text and create an Image:
    if(ref $message ne 'Imager') {
        $message = text_to_image($message);
    } else {
        # Check image size / scale ?
    }

    # Write out image to display:
    my $file_data;
    $message->write(data => \$file_data, type => 'bmp');
    $c->render(data => $file_data, format => 'bmp');    
};

app->start('daemon', '-l', 'http://*:5001');

sub text_to_image ($message) {
    my $default_font = 'Ac437_ApricotPortable.ttf';
    my $fontfile = 'fonts/ttf - Ac (aspect-corrected)/' . $default_font;

    my $font = Imager::Font->new(
        file => $fontfile,
        # face => 'Times New Roman', #placeholder
        color => 'white',
        size => $fontsize,
    );
    if (!$font) {
        die "Couldn't load font";
    }

    my $savepos;
    my $img = Imager->new(xsize => $screensize->{x},
                          ysize => $screensize->{y},
                          type => 'paletted');
    $img->addcolors(colors => [Imager::Color->new(0, 0, 0),
                               Imager::Color->new(255, 255, 255)]);
    say STDERR "img: $img";
    Imager::Font::Wrap->wrap_text(
        image   => $img,
        font    => $font,
        string  => $message,
        savepos => \$savepos,
        # justify => 'fill',
    ) or die $img->errstr;

    if($savepos < length($message)) {
        warn "$message was too long\n";
    }

    return $img;
}

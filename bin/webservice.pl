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

use v5.28;
use Mojolicious::Lite -signatures;
use Imager;
use Imager::Font::Wrap;
use Path::Class;
use Regexp::Common 'profanity';
use Data::Dumper;
use DateTime;
use DateTime::Format::Strptime;
use Data::Printer output => 'stderr';

use lib "$ENV{INFODISPLAY_HOME}/lib";
use MS::InfoDisplay;

if(!$ENV{INFODISPLAY_HOME} || !-e $ENV{INFODISPLAY_HOME}) {
    die "Please set INFODISPLAY_HOME environment variable\n";
}

my $screensize = { x => 3*64, y => 3*32 };
my $fontsize = 16;
my $image_format = 'png';
my $datetime_formatter = DateTime::Format::Strptime->new(
    pattern => '%A %e %B %H:%M'
);

=head2 Web endpoint /message

Answer GET requests to /message

L<Mojolicious::Lite> does all the heavy lifting here, we define some
code (a code reference) that is called when something fetches
L<http://whereever/message>.

=cut

get '/message' => sub ($c) {
    # Look for all plugins:
    my $info_display = MS::InfoDisplay->new();
    my @plugins = $info_display->plugins();

    die "No plugins" if !@plugins;

    my $message;
    if($c->param('plugin')) {
        my $p = $c->param('plugin');
        $message = $p->run($c->param('num') || 0); #params?
    } else {

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

        $message = $plugin_info->{plugin}->run($the_random);

        # If its not an Image, assume its text and create an Image:
        if(ref $message ne 'Imager') {
            $message = text_to_image($message);
        } else {
            # Check image size / scale ?
        }

    }
    
    # Write out image to display:
    my $file_data;
    if(!$message) {
        $message = Imager->new(xsize => $screensize->{x},
                               ysize => $screensize->{y},
        );
    }
    $message = $message->to_paletted(make_colors => 'addi');
    $message->write(data => \$file_data, type => $image_format);
    $c->render(data => $file_data, format => $image_format);    
};

app->start('daemon', '-l', 'http://*:5001');

sub text_to_image ($message) {
#    my $fontfile = '/usr/src/extern/hackspace/TitilliumWeb-Light.ttf';
    my $fontfile = "$ENV{INFODISPLAY_HOME}/fonts/Lekton-Regular.ttf';

    if(!-e $fontfile) {
        say "No such font: $fontfile";
    }

    my $not_white = Imager::Color->new('#444444');
    my $font_clock = Imager::Font->new(
        file => $fontfile,
        color => 'white',
        size => $fontsize,
        aa    => 1
    );

    my $font = Imager::Font->new(
        file => $fontfile,
        color => $not_white,
        size => $fontsize,
        aa   => 1,
    );
    if (!$font) {
        die "Couldn't load font";
    }

    my $savepos;
    my $img = Imager->new(xsize => $screensize->{x},
                          ysize => $screensize->{y},
    #                      type => 'paletted'
    );

    say STDERR "img: $img";
    my $now = DateTime->now(time_zone => 'Europe/London');
    $img->string(x => 0,
                 y => 0,
                 align => 0,
                 font => $font_clock,
                 string => $datetime_formatter->format_datetime($now),
#                 string => sprintf('%s %02d:%02d', DateTime->now()->day_name, DateTime->now()->hour, DateTime->now()->minute),
    );
    Imager::Font::Wrap->wrap_text(
        image   => $img,
        font    => $font,
        x       => 15,
        y       => 18,
        
        string  => $message,
        savepos => \$savepos,
        # justify => 'fill',
    ) or die $img->errstr;

    if($savepos < length($message)) {
        warn "$message was too long\n";
    }

    return $img;
}

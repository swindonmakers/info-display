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
use Path::Class;
use Regexp::Common 'profanity';
use Data::Dumper;

use lib 'lib';
use MS::InfoDisplay;

=head2 Web endpoint /message

Answer GET requests to /message

L<Mojolicious::Lite> does all the heavy lifting here, we define some
code (a code reference) that is called when something fetches
L<http://whereever/message>.

=cut

my $screensize = { x => 128, y => 128 };
my $fontsize = 12;

get '/message' => sub ($c) {
    # Look for all plugins:
    my $info_display = MS::InfoDisplay->new();
    my @plugins = $info_display->plugins();

    # Collect all possible messages
    # One key per message, track which plugin and its arguments in the values
    my %display_messages = ();
    foreach my $plugin (@plugins) {
        foreach my $message_data ($plugin->get_message_counts()) {
            $display_messages{$message_data->{key}} = { plugin => $plugin, %$message_data };
        }
    }

    # Keys as a array:
    my @message_keys = keys %display_messages;

    # Pick a message (random number between 0 and number of messages):
    my $msg_index = int(rand(scalar @message_keys));

    # Retrieve that message's plugin data:
    my $message_data = $display_messages{$message_keys[$msg_index]};

    # Run the plugin:
    my $message = $message_data->{plugin}->run($message_data);

    # If its not an Image, assume its text and create an Image:
    if(ref $message ne 'Imager') {
        $message = text_to_image($message);
    } else {
        # Check image size / scale ?
    }

    # Write out image to display:
    my $file_data;
    $message->write(data => \$file_data, type => 'png');
    $c->render(data => $file_data, format => 'png');    
};

app->start;

sub text_to_image ($message) {

    my $font = Imager::Font->new(
        face => 'Times New Roman', #placeholder
        color => 'white',
        size => $fontsize,
    );

    my $savepos;
    my $img = Imager=>new(xsize => $screensize->{x},
                          ysize => $screensize->{y});
    Imager::Font::Wrap->wrap_text( image   => $img,
                                   font    => $font,
                                   string  => $message,
                                   savepos => \$savepos ) or die $img->errstr;

    if($savepos > 0) {
        warn "$message was too long\n";
    }

    return $img;
}

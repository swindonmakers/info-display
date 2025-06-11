package MS::InfoDisplay::Plugin::AccessStats;

use strictures 2;

use v5.28;
use Config::General;
use Imager::Graph::Column;
use Imager::Font;

BEGIN {
    if($ENV{ACCESS_HOME} && -e $ENV{ACCESS_HOME}) {
        require lib; lib->import("$ENV{ACCESS_HOME}/lib");
        require local::lib; local::lib->import("$ENV{ACCESS_HOME}/local");
        require AccessSystem::Schema; AccessSystem::Schema->import();
    }
}

sub messages_count {
    return $ENV{ACCESS_HOME} ? 1 : 0;
}

sub run {
    return if(!$ENV{ACCESS_HOME});

    my %l_config = Config::General->new("$ENV{ACCESS_HOME}/accesssystem_api_local.conf")->getall;
    my $schema = AccessSystem::Schema->connect(
        $l_config{'Model::AccessDB'}{connect_info}{dsn},
        $l_config{'Model::AccessDB'}{connect_info}{user},
        $l_config{'Model::AccessDB'}{connect_info}{password},
    );

    my $data = $schema->resultset('Person')->membership_stats();

    my $font = Imager::Font->new(
        file => "$ENV{INFODISPLAY_HOME}/fonts/Lekton-Regular.ttf",
        size => 4,
    );
    my $graph = Imager::Graph::Column->new();
    $graph->set_image_width(192);
    $graph->set_image_height(96);
    $graph->set_graph_size(96);
    $graph->set_font($font);
    # $graph->show_horizontal_gridlines();
    $graph->show_graph_outline(0);
    # $graph->show_area_markers();
    # $graph->use_automatic_axis();
    
    # $graph->show_legend();

    # full/tier pairs, conc/tier pairs
    my @data = (
        $data->{full}{valid_members}{MemberOfOtherHackspace},
        $data->{full}{valid_members}{MensShed},
        $data->{full}{valid_members}{Weekend},
        $data->{full}{valid_members}{Standard},
        $data->{full}{valid_members}{Sponsor},
        $data->{concession}{valid_members}{MemberOfOtherHackspace},
        $data->{concession}{valid_members}{MensShed},
        $data->{concession}{valid_members}{Weekend},
        $data->{concession}{valid_members}{Standard},
        $data->{concession}{valid_members}{Sponsor},
    );
    my @labels = qw(
        FMO
        FSH
        FWE
        FST
        FSP
        CMO
        CSH
        CWE
        CST
        CSP
    );

    $graph->add_data_series(\@data, 'Mbrs');
    $graph->set_labels(\@labels);

    my $img = $graph->draw(
        fount_lin=> 0,
        style => 'mono',
        bg => 'black',
        fg => 'white'
    ) || warn $graph->error();
    return $img;
}

1;

package Koha::Plugin::Tamil::Mirabel::Controller;

use Modern::Perl;
use utf8;
use Koha::Plugin::Tamil::Mirabel;
use Mojo::Base 'Mojolicious::Controller';


sub acces {
    my $c = shift->openapi->valid_input or return;

    my $plugin = Koha::Plugin::Tamil::Mirabel->new;
    my $pc     = $plugin->config();
    my $logger = $plugin->{logger};
    my $where  = $c->validation->param('where');
    my $page   = $c->validation->param('page');
    my $issn   = $c->validation->param('issn');
    my $date   = $c->validation->param('date') || '';
    my $conf   = $pc->{acces}->{$where}->{$page};

    my $html   = $plugin->html_acces($issn, $date, $conf);

    $c->render(
        status  => 200,
        openapi => {
            status => 'ok',
            reason => '',
            errors => [],
        },
        json => { html => $html },
    );
}

1;

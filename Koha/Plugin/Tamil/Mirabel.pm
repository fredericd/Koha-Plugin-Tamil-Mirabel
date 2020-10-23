package Koha::Plugin::Tamil::Mirabel;

use Modern::Perl;
use utf8;
use base qw(Koha::Plugins::Base);
use CGI qw(-utf8);
use C4::Context;
use C4::Biblio;
use Koha::Cache;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use Template;



## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'Koha ⇄ Mir@bel',
    description     => 'Interfaçage entre Koha et Mir@bel',
    author          => 'Tamil s.a.r.l.',
    date_authored   => '2019-10-20',
    date_updated    => "2020-10-23",
    minimum_version => '18.11.00.000',
    maximum_version => undef,
    copyright       => '2020',
    version         => '1.0.2',
};


my $DEFAULT_LISTE_TEMPLATE = <<EOS;
<div class="alert alert-success" role="alert">
 <h4 class="alert-heading">Accès en ligne</h4>
 <p>
  Voici la liste des revues détenues à la Bibliothèque, pour lesquels un accès
  en ligne est disponible.
 </p>
</div>
<div>
[% FOREACH t IN titres %]
 <h3>
  [% t.titre %]
  <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% t.identifiantpartenaire %]">
   <img src="/opac-tmpl/bootstrap/images/favicon.ico" title="Voir cette revue dans ce Catalogue"/>
  </a>
  <a href="https://reseau-mirabel.info/revue/[% t.revueid + %]" target="_blank">
   <img src="https://reseau-mirabel.info/images/favicon.ico" width="16px" title="Dans Mir\@bel"/>
  </a>
  <a href="[% t.url %]" target="_blank" title="Chez son éditeur">
   <span style="background-color: #a0a0a0; padding: 2px;  color:white; font-size:11px;">É</span>
  </a>
 </h3>
 <p>
  [% t.editeurs.join(' • ') %]
  ; [% t.periodicite %]
  ;
  [% FOREACH i IN t.issns %]
   [% i.issn %] ([% i.suport %])[% ", " UNLESS loop.last %]
  [% END %]
   ;
  [% t.datedebut %] - [% t.datefin %]
 </p>
 <ul>
  [% FOREACH a IN t.acces %]
   <li>
    <a href="[% a.url %]">[% a.ressource %]</a>,
    [% a.numerodebut %]-[% a.numerofin %],
    [% a.datedebut %]-[% a.datefin %],
    [% a.contenu %] ([% a.diffusion %])
   </li>
  [% END %]
 </ul>
[% END %]
</div>
EOS

my $DEFAULT_BIBLIO_TEMPLATE = <<EOS;
<div id="mirabel" aria-labelledby="ui-id-7" class="ui-tabs-panel ui-widget-content ui-corner-bottom" role="tabpanel" aria-expanded="false" aria-hidden="true" style="display:block; border: 1px solid #c0c0c0; padding: 7px; margin-bottom:0px; margin-top: 5px;">
 <div class="content_set">
  <table class="table table-sm table-condensed table-hover" style="margin-bottom: 0px;">
   <thead class="thead-dark">
    <th>
     <a href="https://reseau-mirabel.info">
      <img src="https://reseau-mirabel.info/images/favicon.ico" width="16px" title="Mir\@bel"/>
     </a> Accès en-ligne
    </th>
    <th>Ressource</th>
    <th>Accès</th>
    <th>Numéros</th>
   </thead>
   <tbody>
    [% FOREACH a IN acces %]
     <tr>
      <td><a href="[% a.url %]">[% a.contenu %]</a></td>
      <td><a href="https://reseau-mirabel.info/ressource/[% a.ressourceid %]">[% a.ressource %]</td>
      <td>[% a.diffusion %]</td>
      <td>
       [% a.datedebut %]
       [% IF a.numerodebut %]([% a.numerodebut %])[% END %]
       —
       [% IF a.datefin != "" %]
         [% a.datefin %]
         [% IF a.numerofin %]([% a.numerofin %])[% END %]
       [% ELSE %]
         ...
       [% END %]
      <td>
     <tr>
    [% END %]
   </tbody>
  </table>
 </div>
</div>
EOS


sub new {
    my ($class, $args) = @_;

    $args->{metadata} = $metadata;
    $args->{metadata}->{class} = $class;
    $args->{cache} = Koha::Cache->new();

    $class->SUPER::new($args);
}


sub config {
    my $self = shift;

    my $c = $self->{args}->{c};
    unless ($c) {
        $c = $self->retrieve_data('c');
        if ($c) {
            utf8::encode($c);
            $c = decode_json($c);
        }
        else {
            $c = {};
        }
    }
    $c->{url} ||= {};
    $c->{url}->{web} ||= 'https://reseau-mirabel.info';
    $c->{url}->{api} ||= 'https://reseau-mirabel.info/api';
    $c->{url}->{timeout} ||= 600;
    $c->{opac}->{liste}->{template} ||= $DEFAULT_LISTE_TEMPLATE;
    $c->{opac}->{biblio}->{template} ||= $DEFAULT_BIBLIO_TEMPLATE;
    $c->{metadata} = $self->{metadata};

    $self->{args}->{c} = $c;

    return $c;
}


sub get_form_config {
    my $cgi = shift;
    my $c = {
        url => {
            web     => undef,
            api     => undef,
            timeout => undef,
        },
        partenaire => {
            id  => undef,
            cle => undef,
        },
        opac => {
            liste => {
                template => undef,
            },
            biblio => {
                active => undef,
                affiche => {
                    ou => undef,
                    id => undef,
                },
                cherche => undef,
                template => undef,
            }
        }
    };

    my $set;
    $set = sub {
        my ($node, $path) = @_;
        return if ref($node) ne 'HASH';
        for my $subkey ( keys %$node ) {
            my $key = $path ? "$path.$subkey" : $subkey;
            my $subnode = $node->{$subkey};
            if ( ref($subnode) eq 'HASH' ) {
                $set->($subnode, $key);
            }
            else {
                $node->{$subkey} = $cgi->param($key);
            }
        }
    };

    $set->($c);
    return $c;
}


sub configure {
    my ($self, $args) = @_;
    my $cgi = $self->{'cgi'};

    if ( $cgi->param('save') ) {
        my $c = get_form_config($cgi);
        $self->store_data({ c => encode_json($c) });
        print $self->{'cgi'}->redirect(
            "/cgi-bin/koha/plugins/run.pl?class=Koha::Plugin::Tamil::Mirabel&method=tool");
    }
    else {
        my $template = $self->get_template({ file => 'configure.tt' });
        $template->param( c => $self->config() );
        $self->output_html( $template->output() );
    }
}


sub install() {
    my ($self, $args) = @_;
}


sub upgrade {
    my ($self, $args) = @_;

    my $dt = DateTime->now();
    $self->store_data( { last_upgraded => $dt->ymd('-') . ' ' . $dt->hms(':') } );

    return 1;
}


sub uninstall() {
    my ($self, $args) = @_;
}


sub ws() {
    my ($self, $service, $param) = @_;

    my $c   = $self->config();
    my $api = $c->{url}->{api};
    my $cle = $c->{partenaire}->{cle};
    my $ua  = $self->{ua} ||= Mojo::UserAgent->new;
    my $url = $api . $service;
    $param ||= {};
    if ( $param->{partenaire} && $param->{partenaire} eq 'delete' ) {
        delete $param->{partenaire};
    }
    elsif ($cle) {
        $param->{partenaire} = $cle;
    }
    else {
        delete $param->{possession};
    }
    $url .= '?' . join('&', map { "$_=" . $param->{$_} } keys %$param)
      if keys %$param;

    my $res = $ua->get($url)->result;
    return $res ? $res->json : undef;
}


sub get_titres {
    my $self = shift;

    my $titres = $self->{cache}->get_from_cache('titres');
    unless ($titres) {
        if ( $titres = $self->ws('/mes/titres', {possession=>1}) ) {
            return [] if ref($titres) ne 'ARRAY';
            for my $titre (@$titres) {
                my $id = $titre->{revueid};
                $titre->{acces} = $self->ws('/acces/revue', {revueid => $id});
            }
            my $c = $self->config();
            $self->{cache}->set_in_cache(
                'titres', $titres, { expiry => $c->{url}->{timeout} });
        }
    }
    return $titres;
}


sub html_titres {
    my $self = shift;

    if ( my $titres = $self->get_titres() ) {
        my $c = $self->config();
        my $template = Template->new();
        my $text = $c->{opac}->{liste}->{template};
        my $html = '';
        $template->process(\$text, { titres => $titres }, \$html)
            or die "Mauvais template liste : " . $template->error();
        return $html;
    }     
}


sub get_all_acces {
    my $self = shift;

    my $acces = $self->{cache}->get_from_cache('acces');
    unless ($acces) {
        if ( $acces = $self->ws('/mes/acces', {possession => 1}) ) {
            return [] if ref($acces) ne 'ARRAY';
            $acces = [ sort { $a->{ressource} cmp $b->{ressource} } @$acces ];
            my %titre = map { $_->{titreid} => {} } @$acces;
            for my $id ( keys %titre ) {
                $titre{$id} = $self->ws("/titres/$id", {partenaire => 'delete'});
            }
            for (@$acces) {
                $_->{titre} = $titre{ $_->{titreid} };
            }
            my $c = $self->config();
            $self->{cache}->set_in_cache(
                'acces', $acces, { expiry => $c->{url}->{timeout} });
        }
    }
    return $acces;
}


sub get_acces {
    my ($self, $id) = @_;

    my $key = "acces_$id";
    my $acces = $self->{cache}->get_from_cache($key);
    unless ($acces) {
        if ( $acces = $self->ws('/acces/titres', {issn => $id, possession => 1}) ) {
            $acces = [ sort { $a->{ressource} cmp $b->{ressource} } @$acces ];
            my $c   = $self->config();
            $self->{cache}->set_in_cache(
                $key, $acces, { expiry => $c->{url}->{timeout} })
        }
    }
    return $acces;
}


sub html_acces {
    my ($self, $id) = @_;

    if ( my $acces = $self->get_acces($id) ) {
        my $c = $self->config();
        my $template = Template->new();
        my $text = $c->{opac}->{biblio}->{template};
        my $html = '';
        $template->process(\$text, { acces => $acces }, \$html)
            or die "Mauvais template biblio : " . $template->error();
        return $html;
    }     
}


sub tool {
    my ($self, $args) = @_;

    my $cgi = $self->{'cgi'};

    my $template;
    my $tool = $cgi->param('tool');
    if ( $tool ) {
        if ($tool eq 'acces') {
            $template = $self->get_template({ file => 'acces.tt' });
            $template->param( acces => $self->get_all_acces() );
        }
        elsif ($tool eq 'titres') {
            $template = $self->get_template({ file => 'titres.tt' });
            $template->param( titres => $self->get_titres() );
        }
    }
    else {
        $template = $self->get_template({ file => 'home.tt' });
    }
    $template->param( c => $self->config() );
    $template->param( TOOL => $tool ) if $tool;
    $self->output_html( $template->output() );
}


sub intranet_js {
    my $self = shift;

    q|
      <script>
        $(document).ready(function(){
          if ( $('body').is("#tools_tools-home") ) {
            $('.container-fluid .col-sm-4:nth-child(2) dl').append(
             '<dt><a href="/cgi-bin/koha/plugins/run.pl?class=Koha::Plugin::Tamil::Mirabel&method=tool">Koha ⇄ Mir@bel</a></dt>' +
             '<dd>Interfaçage de Mir@bel avec Koha</dd>');
          }
          $('#toplevelmenu li:last-child ul').append(
            '<li>' +
            '<a href="/cgi-bin/koha/plugins/run.pl?class=Koha::Plugin::Tamil::Mirabel&method=tool">Koha ⇄ Mir@bel</a>' +
            '</li>'
          );
        });
      </script>
    |;
}


sub opac_js {
    my $self = shift;

    my $url = $ENV{REQUEST_URI};
    return if $url !~ /opac-detail\.pl|opac-main\.pl/;

    return $url =~ /opac-detail/ ? $self->opac_detail()
                                 : $self->opac_liste();
}


sub opac_detail {
    my $self = shift;
    my $c = $self->config();

    return if $c->{opac}->{biblio}->{active} == 0;

    # On ne fait rien si on n'est pas sur la page de détail, sur une notice
    # qui a un ISSN
    my $url = $ENV{REQUEST_URI};
    return unless $url =~ /biblionumber=([0-9]+)/;
    my $biblionumber = $1;
    my $sth = C4::Context::dbh->prepare("
        SELECT issn FROM biblioitems WHERE biblionumber = ?");
    $sth->execute($biblionumber);
    my ($issn) = $sth->fetchrow;
    return unless $issn;

    my $acces = $self->html_acces($issn);
    $acces = encode_json($acces);
    utf8::decode($acces);
    my $biblio = $c->{opac}->{biblio};
    my $location = $biblio->{affiche}->{ou};
    my $id       = $location eq 'div' ? $biblio->{affiche}->{id} :
                   $location eq 'ex_dessus' ? '#catalogue_detail_biblio' : 0;

    return <<EOS;
<script>
\$(document).ready(function(){
  function mirabelAcces(location,html) {
      if (location !== '0') {
        \$(location).append(html);
      } else {
        var tabMenu = "<li class='ui-state-default ui-corner-top' role='tab' tabindex='-1' aria-controls='mirabel' aria-labelledby='ui-id-7' aria-selected='false'><a href='#mirabel' class='ui-tabs-anchor' role='presentation' tabindex='-1' id='ui-id-7'>Mir\@bel</a></li>";
        var tabs = \$('#bibliodescriptions').tabs();
        var ul = tabs.find("ul");
        \$(ul).append(tabMenu);
        \$(tabs).append(html);
        tabs.tabs("refresh");
      }
  }

  mirabelAcces('$id', $acces);

});
</script>
EOS

}


sub opac_liste {
    my $self = shift;

    my $url = $ENV{REQUEST_URI};
    return unless $url =~ /mirabel=liste/;

    my $titres = $self->html_titres();
    $titres = encode_json($titres);
    utf8::decode($titres);

    return <<EOS;
<script>
\$(document).ready(function(){
  var id = \$('.main .span7').hide();
  id.html($titres);
  id.show();
  \$('.breadcrumb a').attr('href', '/');
});
</script>
EOS

}

1;

package Koha::Plugin::Tamil::Mirabel;

use Modern::Perl;
use utf8;
use base qw(Koha::Plugins::Base);
use CGI qw(-utf8);
use Koha::Cache;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use Template;
use JSON qw/ to_json /;
use List::Util qw/ first /;
use Pithub::Markdown;
use YAML;



## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'Koha ⇄ Mir@bel',
    canonicalname   => 'koha-plugin-tamil-mirabel',
    description     => 'Interfaçage entre Koha et Mir@bel',
    author          => 'Tamil s.a.r.l.',
    date_authored   => '2019-10-20',
    date_updated    => "2024-07-01",
    minimum_version => '22.11.00.000',
    maximum_version => undef,
    copyright       => '2024',
    version         => '2.0.0',
};


my $DEFAULT_TEMPLATE_REVUES = <<EOS;
<div class="alert alert-success" role="alert">
 <h4 class="alert-heading">Accès en ligne</h4>
 <p>
  Voici la liste des revues détenues à la Bibliothèque, pour lesquels un accès
  en ligne est disponible.
 </p>
</div>
<div>
[% FOREACH titres IN revues %]
 [% premier = titres.0 %]
 <h3>
  [% premier.titre %]
  <a href="https://reseau-mirabel.info/revue/[% premier.revueid %]" target="_blank">
   <img src="https://reseau-mirabel.info/images/favicon.ico" width="16px" title="Dans Mir\@bel"/>
  </a>
 </h3>
 <ul>
  [% FOREACH titre IN titres %]
   [% biblionumber = titre.acces.0.identifiantpartenaire %]
   <li>
    [% IF biblionumber %]
     <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% biblionumber %]" title="Voir dans le catalogue" target="_blanck">
      [% titre.prefixe %][% titre.titre %]
     </a>
    [% ELSE %]
     [% titre.prefixe %][% titre.titre %]
    [% END %]
    [% IF titre.url %]
     <a href="[% titre.url %]" target="_blank" title="Chez son éditeur">
      <span style="background-color: #a0a0a0; padding: 2px;  color:white; font-size:11px;">É</span>
     </a>
    [% END %]
    :
    [% titre.datedebut %]-[% titre.datefin %],
    [% IF titre.periodicite %][% titre.periodicite %], [% END %]
    [% FOREACH editeur IN titre.editeurs %]
     [% editeur %][% IF ! loop.last %], [% END %]
    [% END %]
    [% IF titre.acces %]
     <ul>
      [% FOREACH a IN titre.acces %]
       <li>
        <a href="[% a.urlproxy || a.url %]">[% a.ressource %]</a>,
        [% a.contenu %], [% a.diffusion %],
        [% IF a.datedebut %]
         [% a.datedebut %]
         [%IF a.numerodebut %]([% a.numerodebut %])[% END %]
        [% END %]
        [% IF a.datefin %]
         -
         [% a.datefin %]
         [%IF a.numerofin %]([% a.numerofin %])[% END %]
        [% END %]
        [% IF a.lacunaire %][lacunaire][% END %]
       </li>
      [% END %]
     </ul>
    [% END %]
   </li>
  [% END %]
 </ul>
[% END %]
EOS

my $DEFAULT_TEMPLATE_ACCES = <<EOS;
<style>
#mirabel ul li {
  list-style-type: disc;
}
</style>
<div id="mirabel" aria-labelledby="ui-id-7"
  class="ui-tabs-panel ui-corner-bottom"
  role="tabpanel" aria-expanded="false" aria-hidden="true"
  style="display:block; background: white; border: 1px solid #c0c0c0; padding: 7px; margin-bottom:0px; margin-top: 5px;"
>
 <div class="content_set">
  <p>
   <img src="https://reseau-mirabel.info/images/favicon.ico" width="16px" title="Mir\@bel"/>
   Accès en ligne à la revue via
   <a href="https://reseau-mirabel.info/revue/titre-id/[% acces.0.titreid %]">Mir\@bel</a>
  </p>
  [% IF conf.mode == 'tableau' %]
   <table class="table table-sm table-condensed table-hover" style="margin-bottom: 0px;">
    <thead class="thead-dark">
     <th>Accès</th>
     <th>Ressource</th>
     <th>Modalité</th>
     <th>Numéros</th>
    </thead>
    <tbody>
     [% FOREACH a IN acces %]
      <tr>
       <td><a href="[% a.urlproxy || a.url %]">[% a.contenu %]</a></td>
       <td>[% a.ressource %]</td>
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
        [% IF a.lacunaire %] [lacunaire][% END %]
        [% IF a.dateinfo %] / [% a.dateinfo %][% END %]
       </td>
      <tr>
     [% END %]
    </tbody>
   </table>
  [% ELSE %]
   <ul>
    [% FOREACH a IN acces %]
     <li>
      <a href="[% a.urlproxy || a.url %]">
       [% a.datedebut %]
       [% IF a.numerodebut %]([% a.numerodebut %])[% END %]
       —
       [% IF a.datefin != "" %]
        [% a.datefin %]
        [% IF a.numerofin %]([% a.numerofin %])[% END %]
       [% ELSE %]
        ...
       [% END %]
      </a>
      [% IF a.lacunaire %] [lacunaire][% END %]
      [% IF a.dateinfo %] / [% a.dateinfo %][% END %]
      /
      [% a.ressource %]
      [% UNLESS conf.cacher.search('contenu') %]; [% a.contenu %][% END %]
      [% UNLESS conf.cacher.search('diffusion') %]; [% a.diffusion %][% END %]
     </li>
    [% END %]
   </ul>
  [% END %]
 </div>
</div>
EOS


sub new {
    my ($class, $args) = @_;

    $args->{metadata} = $metadata;
    $args->{metadata}->{class} = $class;
    $args->{cache} = Koha::Cache->new();
    $args->{logger} = Koha::Logger->get({ interface => 'api' });

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
    $c->{template}->{revues} ||= $DEFAULT_TEMPLATE_REVUES;
    $c->{template}->{acces} ||= $DEFAULT_TEMPLATE_ACCES;
    $c->{acces}->{sort} ||= <<EOS;
contenu:Intégral,Résumé,Sommaire,Indexation
datedebut:asc
diffusion:libre,abonné,restreint
ressource:asc
EOS
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
        template => {
            revues => undef,
            acces => undef,
        },
        acces => {
            sort => undef,
        },
    };
    for my $where (qw/ opac pro /) {
        for my $page (qw/ detail result /) {
            for my $date (qw/ sans avec /) {
                $c->{acces}->{$where}->{$page}->{$date}->{$_} = undef
                    for qw/active mode revue exclure cacher date/;
            }
        }
    }

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
                #my $value = $cgi->param("$key");
                #$value = '' unless defined($value);
                #$node->{$subkey} = $value;
                my @values = $cgi->multi_param("$key");
                @values = map { s/\r//g; $_; } @values;
                $node->{$subkey} = join(',', @values);
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
    $url .= '?' . join('&', map { "$_=" . $param->{$_} } keys %$param)
      if keys %$param;

    my $res = $ua->get($url)->result;
    return $res ? $res->json : undef;
}


sub html_revues {
    my $self = shift;

    if ( my $revues = $self->get_revues() ) {
        my $c = $self->config();
        my $template = Template->new();
        my $text = $c->{template}->{revues};
        my $html = '';
        $template->process(\$text, { revues => $revues }, \$html)
            or $html = "Mauvais template revues : " . $template->error();
        return $html;
    }
}


sub get_revues {
    my $self = shift;

    my $revues = $self->{cache}->get_from_cache('revues');
    unless ($revues) {
        if ( my $acces = $self->ws('/mes/acces', { possession => 1, abonnement => 0 }) ) {
            return [] if ref($acces) ne 'ARRAY';
            $acces = [ sort { $a->{ressource} cmp $b->{ressource} } @$acces ];
            my %titre = map { $_->{titreid} => undef } @$acces;
            my @ids = sort { $a <=> $b } keys %titre;
            my $OFFSET = 500;
            while (@ids) {
                my @search_ids = splice(@ids, 0, $OFFSET);
                my $titres = $self->ws("/titres?id=" . join(',', @search_ids), {partenaire => 'delete'});
                $titre{$_->{id}} = $_  for @$titres;
            }
            for my $a (@$acces) {
                my $titreid = $a->{titreid};
                my $revueid = $titre{$titreid}->{revueid};
                $revues->{$revueid} ||= [];
                my $titres = $revues->{$revueid};
                my $titre = first { $_->{id} == $titreid } @$titres;
                unless ($titre) {
                    $titre = $titre{$titreid};
                    $titre->{acces} = [];
                    push @$titres, $titre;
                }
                my $clone = {};
                for my $name (keys %$a) {
                    $clone->{$name} = $a->{$name};
                }
                push @{$titre->{acces}}, $clone;
            }
            # On réordonne les titres de chaque revue par date de début inverse
            while (my ($revueid, $titres) = each %$revues) {
                next if @$titres == 1;
                $revues->{$revueid} = [ sort {
                    ($b->{datedebut} || 0) cmp ($a->{datedebut} || 0)
                } @$titres ];
            }
            # On trie par 1er titre
            $revues = [ sort {
                $a->[0]->{titre} cmp $b->[0]->{titre}
            } values %$revues ];

            my $c = $self->config();
            $self->{cache}->set_in_cache(
                'revues', $revues, { expiry => $c->{url}->{timeout} });
        }
    }
    return $revues;
}


sub acces_filter {
    my ($self, $acces, $date, $conf) = @_;

    my $logger = $self->{logger};

    # Exclure certains accès identifiés par contenu/diffusion
    if (my @exclure = split /,/, $conf->{exclure}) {
        my %exclure;
        for my $contenu (@exclure) {
            if ($contenu =~ /^(.*)-(.*)$/) {
                $exclure{$1}->{$2} = 1;
            }
            else {
                $exclure{$contenu} = 1;
            }
        }
        $acces = [ grep {
            my $keep = 1;
            if (my $found = $exclure{$_->{contenu}}) {
                if (ref($found) eq 'HASH') {
                    $keep = 0 if $found->{$_->{diffusion}};
                }
                else {
                    $keep = 0;
                }
            }
            $keep;
        } @$acces ];
    }

    # Exclure les accès qui ne correspondent pas à la date donnée
    if ($conf->{date} && $date && $date =~ /^[0-9]{4}$/) {
        $logger->debug("Filtrage des accès par date: $date");
        $acces = [ grep {
            my $keep = 1;
            my $debut = $_->{datedebut};
            $debut = $1 if $debut =~ /^([0-9]{4})/;
            my $fin = $_->{datefin} || 2999;
            $fin = $1 if $fin =~ /^([0-9]{4})/;
            $keep = 0 if $debut && $date < $debut;
            $keep = 0 if $fin && $date > $ fin;
            $logger->debug("debut: $debut - fin: $fin - keep: $keep");
            $keep;
        } @$acces ];
    }
    
    # Tri
    my $c = $self->config();
    my $sort = $c->{acces}->{sort};
    $sort = [ split /\n/, $sort ];
    $logger->debug(Dump($sort));
    my $key = sub {
        my $a = shift;
        my @k;
        for my $k (@$sort) {
            my ($what, $order) = split /:/, $k;
            my $value = $a->{$what};
            next unless $value;
            # Ne garder que l'année des champs date
            $value = $1 if $what =~ /date/ && $value =~ /^([0-9]{4})/;
            if ($order =~ /desc/) {
                if ($what =~ /date/) {
                    $value = 3000 - $value;
                }
            }
            if ($order =~ /,/) {
                my @order = split /,/, $order;
                my $k;
                for (my $i=0; $i < @order; $i++) {
                    $k = $i + 1 if $value eq $order[$i];
                }
                $k = 9 unless $k;
                $value = "$k~$value";
            }
            push @k, $value;
        }
        my $k = join('-', @k);
        return $k;
    };
    for my $a (@$acces) {
        $logger->debug("CLÉ: " . $key->($a));
    }
    $acces = [ sort {
        $key->($a) cmp $key->($b);
    } @$acces ];

    return $acces;
}


sub get_acces {
    my ($self, $id, $date, $conf) = @_;

    my $mode = $conf->{revue} ? 'rev' : 'tit';
    my $key = "$mode-$id";
    my $acces = $self->{cache}->get_from_cache($key);
    unless ($acces) {
        my $url = $mode eq 'rev' ? '/acces/revue' : '/acces/titres';
        if ( $acces = $self->ws($url, { issn => $id }) ) {
             if (ref($acces) eq 'HASH' && $acces->{code}) {
                 $acces = [];
             }
             my $c   = $self->config();
             $self->{cache}->set_in_cache(
                 $key, $acces, { expiry => $c->{url}->{timeout} })
        }
    }

    return $self->acces_filter($acces, $date, $conf);
}


sub html_acces {
    my ($self, $id, $date, $conf) = @_;

    my $acces = $self->get_acces($id, $date, $conf);
    return "" unless @$acces;

    my $c = $self->config();
    my $template = Template->new();
    my $text = $c->{template}->{acces};
    my $html = '';
    $template->process(\$text, { acces => $acces, conf => $conf }, \$html)
        or $html = "Mauvais template Accès : " . $template->error();
    return $html;
}


sub tool {
    my ($self, $args) = @_;

    my $cgi = $self->{'cgi'};

    my $template;
    my $tool = $cgi->param('tool');
    if ( $tool ) {
        if ($tool eq 'revues') {
            $template = $self->get_template({ file => 'revues.tt' });
            $template->param( revues => $self->get_revues() );
        }
    }
    else {
        $template = $self->get_template({ file => 'home.tt' });
        my $cache = $self->{cache};
        my $key = "mirabel-home";
        my $markdown = $cache->get_from_cache($key);
        unless ($markdown) {
            my $text = $self->mbf_read("home.md");
            utf8::decode($text);
            my $response = Pithub::Markdown->new->render(
                data => {
                    text => $text,
                    context => "github/gollum",
                },
            );
            $markdown = $response->raw_content;
            utf8::decode($markdown);
            $cache->set_in_cache($key, $markdown, { expiry => 3600 });
        }
        $template->param( markdown => $markdown );
    }
    $template->param( c => $self->config() );
    $template->param( TOOL => $tool ) if $tool;
    $self->output_html( $template->output() );
}


sub intranet_js {
    my $self = shift;

    my $url = $ENV{REQUEST_URI};

    return $url =~ /detail\.pl/ ? $self->page_mirabel('pro', 'detail') :
           $url =~ /search\.pl/ ? $self->page_mirabel('pro', 'result') :
                                 undef;
}


sub opac_js {
    my $self = shift;

    my $url = $ENV{REQUEST_URI};

    return $url =~ /opac-main\.pl/   ? $self->opac_liste() :
           $url =~ /opac-detail\.pl/ ? $self->page_mirabel('opac', 'detail') :
           $url =~ /opac-search\.pl/ ? $self->page_mirabel('opac', 'result') :
                                       undef;
}


sub page_mirabel {
    my ($self, $where, $page) = @_;

    my $c = $self->config();
    my $conf = $c->{acces}->{$where}->{$page};
    $conf = to_json($conf);
    
    return <<EOS;
<script>
\$(document).ready(function(){
  function mirabelAcces() {
    let conf = $conf;
    \$('.mirabel-issn').each(function(){
      const iddiv = \$(this);
      const issn = \$(this).attr('issn');
      const date = \$(this).attr('date');
      let url = `/api/v1/contrib/mirabel/acces/$where/$page?issn=\${issn}`;
      let active;
      if (date) {
        url = `\${url}&date=\${date}`;
        active = conf.avec.active;
      } else {
        active = conf.sans.active;
      }
      console.log(url);
      if (! active) {
        console.log('Pas activé. On quitte.');
        return;
      }
      \$.getJSON(url, function(res) {
        console.log(`trouvé \${issn}`);
        iddiv.html(res.html);
        iddiv.show();
      });
    });
  }
  mirabelAcces();
});
</script>
EOS
}


sub opac_liste {
    my $self = shift;

    my $url = $ENV{REQUEST_URI};
    return unless $url =~ /mirabel=liste/;

    my $titres = $self->html_revues();
    $titres = encode_json($titres);
    utf8::decode($titres);

    my $more_than_2011 = C4::Context->preference('Version') ge '20.11' ? 1 : 0;
    my $div_id = $more_than_2011 ? "'.maincontent'" : "'.main .span7'";

    return <<EOS;
<script>
\$(document).ready(function(){
  var id = \$($div_id).hide();
  id.html($titres);
  id.show();
  \$('.breadcrumb a').attr('href', '/');
});
</script>
EOS

}


sub api_namespace {
    return 'mirabel';
}


sub api_routes {
    my $self = shift;
    my $spec_str = $self->mbf_read('openapi.json');
    my $spec     = decode_json($spec_str);
    return $spec;
}

1;

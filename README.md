# Extension Koha ⇄ Mir@bel

**Koha ⇄ Mir@bel** est un plugin de Koha qui étend les fonctionnalités de Koha
en y intégrant les accès en ligne aux revues repérées dans Mir@bel.

[Mir@bel](https://reseau-mirabel.info) est une **base de connaissances
mutualisée des accès en ligne aux revues en sciences humaines francophones**.
Les conditions d'accès aux revues peuvent être libre, restreintes ou sous
abonnement. Il y a des accès au texte intégral des revues, aux sommaires des
numéros, à l'indexation des articles ou à leur résumé. La période de publication
de la revue couverte par chaque accès, ainsi que les lacunes et les conditions
d'accès sont également disponibles. Mir@bel est géré par un réseau de
**partenaires**. Ce sont les bibliothèques et centres de documentation qui sont
autorisés à mettre à jour Mir@bel et à récupérer localement les informations de
Mir@bel au moyen de services web.

L'extension Koha ⇄ Mir@bal permet à un Partenaire de Mir@bel qui gère son
Catalogue de bibliothèque dans le SIGB Koha de faire remonter dans son OPAC Koha
les informations de la base de connaissances Mir@bel. Ces échanges sont réalisés
au moyens des [Service Web](https://reseau-mirabel.info/api) de Mir@bel.

Les informations Mir@bel apparaissent à l'OPAC à deux endroits :

1. **Liste des revues** — Une URL de l'OPAC affiche la liste de toutes les
   revues du partenaire avec pour chaque revue ses points d'accès signalés dans
   Mir@bel.
2. **Liste des accès** — Dans la page de détail d'une notice bibliographique
   d'un périodique tous ses accès sont affichés.

Pour les établissements non-partenaires Mir@bel, il est possible d'utiliser le
plugin. Seule la liste des accès sera affichée sur la page de détail.

## Installation

**Activation des plugins** — Si ce n'est pas déjà fait, dans Koha, activez les
plugins. Demandez à votre prestataire Koha de le faire, ou bien vérifiez les
points suivants :

* Dans `koha-conf.xml`, activez les plugins.
* Dans le fichier de configuration d'Apache, définissez l'alias `/plugins`. 
* Activez la préférence système `UseKohaPlugins` pour les Koha avant la version
  20.05. 

**▼ TÉLÉCHARGEMENT ▼** — Récupérez sur le site [Tamil](https://www.tamil.fr)
l'archive de l'Extension **[Koha ⇄
Mir@bel](https://www.tamil.fr/download/koha-plugin-tamil-mirabel-1.0.8.kpz)**.

**Installation** — Dans l'interface pro de Koha, allez dans Outils > Outils de
Plugins. Cliquez sur Télécharger un plugin. Choisissez l'archive téléchargée à
l'étape précédente. Cliquez sur Télécharger.

**Configuration** — Dans les Outils de plugins, vous voyez l'Extension *Koha ⇄
Mir@bel*. Cliquez sur Actions > Configurer. Il faudra saisir un _ID Partenaire_
Mir@bel valide pour activer les fonctionnalités avancée de l'extension.

## Utilisation de l'extension

### Liste des revues

La liste des revues gérées dans Koha pour lesquelles des accès en ligne sont
proposés via Mir@bel est accessible à cette URL :

```
<OPAC_KOHA>/cgi-bin/koha/opac-main.pl?mirabel=liste
```

Créez un lien vers cette URL sur la page d'Accueil de votre OPAC. Par exemple :

```html
<a href="/cgi-bin/koha/opac-main.pl?mirabel=liste">Nos revues accessibles en ligne</a>
```

Le formatage de la liste des revues est assuré par un template d'affichage. Un
template est fourni par défaut, que vous pouvez modifier. Le système de
traitement de template est le même que celui utilisé dans Koha : [Template
Toolkit](http://www.template-toolkit.org).

L'extension Mir@el envoie au template une variable appelée `titres` qui est un
tableau de titres de revues, avec pour chacune un tableau de ses accès. Par
exemple :

```json
[ 
   { 
      "acces":[ 
         { 
            "contenu":"Intégral",
            "datedebut":"1956",
            "datefin":"2009",
            "diffusion":"restreint",
            "id":9674,
            "nodebut":1,
            "numerodebut":"Vol. 1, no 1",
            "ressource":"SAGE journals online",
            "ressourceid":253,
            "titreid":1012,
            "url":"http:\/\/journals.sagepub.com\/loi\/asj",
            "voldebut":1
         },
         { 
            "contenu":"Sommaire",
            "datedebut":"1993-01",
            "datefin":"2019-09",
            "diffusion":"libre",
            "id":11134,
            "mailurl":"https:\/\/signal.sciencespo-lyon.fr\/alerte\/revue?revueId=392",
            "nodebut":1,
            "nofin":3,
            "numerodebut":"Vol. 36, no 1",
            "numerofin":"Vol. 62, no 3",
            "ressource":"Sign@l",
            "ressourceid":296,
            "rssurl":"https:\/\/signal.sciencespo-lyon.fr\/rss\/rss.php?flux=signal-sommaires-revue&param=392",
            "titreid":1012,
            "url":"https:\/\/signal.sciencespo-lyon.fr\/revue\/392",
            "voldebut":36,
            "volfin":62
         },
         { 
            "contenu":"Intégral",
            "datedebut":"1955-01-01",
            "datefin":"2015-11-01",
            "diffusion":"restreint",
            "embargoinfo":"P4Y",
            "id":14119,
            "nodebut":1,
            "nofin":4,
            "numerodebut":"Vol. 1, no 1",
            "numerofin":"Vol. 58, no 4",
            "ressource":"JSTOR",
            "ressourceid":143,
            "titreid":1012,
            "url":"https:\/\/www.jstor.org\/journal\/actasoci",
            "voldebut":1,
            "volfin":58
         },
         { 
            "contenu":"Intégral",
            "datedebut":"1975-01-03",
            "datefin":"2002-12-31",
            "diffusion":"restreint",
            "id":19178,
            "ressource":"EBSCOhost - Business Source Complete",
            "ressourceid":238,
            "titreid":1012,
            "url":"http:\/\/search.ebscohost.com\/direct.asp?db=bth&jid=ACT&scope=site"
         }
      ],
      "bouquetpartenaire":null,
      "datedebut":"1955",
      "datefin":null,
      "editeurs":[ 
         "Scandinavian University Press"
      ],
      "id":1012,
      "identifiantpartenaire":"81793",
      "issns":[ 
         { 
            "issn":"0001-6993",
            "issnl":"0001-6993",
            "statut":"valide",
            "sudocnoholding":false,
            "sudocppn":"038657856",
            "suport":"papier",
            "worldcatocn":"471992889"
         },
         { 
            "issn":"1502-3869",
            "issnl":"0001-6993",
            "statut":"valide",
            "sudocnoholding":false,
            "sudocppn":"058349782",
            "suport":"electronique",
            "worldcatocn":"56628041"
         }
      ],
      "langues":[ 
         "eng"
      ],
      "obsoletepar":null,
      "periodicite":"trimestriel",
      "prefixe":null,
      "revueid":978,
      "titre":"Acta Sociologica : Journal of the Scandinavian Sociological Association",
      "url":"http:\/\/asj.sagepub.com\/",
      "url_revue_mirabel":"https:\/\/reseau-mirabel.info\/revue\/978"
   },
   {
       etc.
   }
```



### Liste des accès

Dans Koha, sur la page de détail d'une notice de périodique, les accès fournis
par Mir@bel peuvent être affichés. Cette affichage est pilotée par la section
_Affichage avec les notices à l'OPAC_ de la configuration :

* **Activer** pour activer/désactiver l'affichage.
* **Emplacement** pour sélectionner l'emplacement où afficher les accès en-ligne :
  * **Dans le pavé biblio** pour afficher les accès au milieu de la notice, à un
    emplacement repéré par un identifiant html, par exemple : `.publisher`
  * **Entre le pavé biblio et les exemplaires**
  * **Dans un nouvel onglet du pavé des exemplaires**
* **Recherche par** pour spécifier la clé de recherche de la revue dans Mir@bel
  : l'ISSN, le biblionumber Koha ou le PPN Sudoc. Pour le moment, seul l'ISSN
  est pris en compte.
* **Template** — L'affichage est déterminé par un _template_ fourni par défaut.
  Vous pouvez le modifier.

L'extension Mir@bel envoie au template la variable `acces` qui contient un
tableau des accès à la revue. Par exemple :

```json
[ 
   { 
      "contenu":"Résumé",
      "datedebut":"2003-12",
      "diffusion":"libre",
      "id":7978,
      "nodebut":150,
      "numerodebut":"no 150",
      "ressource":"Actes de la recherche en sciences sociales",
      "ressourceid":868,
      "rssurl":"http:\/\/www.arss.fr\/feed\/",
      "titreid":28,
      "url":"http:\/\/www.arss.fr\/sommaires\/"
   },
   { 
      "contenu":"Intégral",
      "datedebut":"2001",
      "datefin":"2016",
      "dateinfo":"Barrière mobile de 2 ans",
      "diffusion":"libre",
      "id":4916,
      "nodebut":136,
      "numerodebut":"no 136",
      "ressource":"Cairn.info",
      "ressourceid":3,
      "titreid":28,
      "url":"http:\/\/www.cairn.info\/revue-actes-de-la-recherche-en-sciences-sociales.htm"
   },
   { 
      "contenu":"Sommaire",
      "datedebut":"1975",
      "datefin":"2019-09",
      "diffusion":"libre",
      "id":4588,
      "mailurl":"https:\/\/signal.sciencespo-lyon.fr\/alerte\/revue?revueId=26",
      "nodebut":1,
      "nofin":229,
      "numerodebut":"Vol. 1, no 1",
      "numerofin":"no 229",
      "ressource":"Sign@l",
      "ressourceid":296,
      "rssurl":"https:\/\/signal.sciencespo-lyon.fr\/rss\/rss.php?flux=signal-sommaires-revue&param=26",
      "titreid":28,
      "url":"https:\/\/signal.sciencespo-lyon.fr\/revue\/26",
      "voldebut":1
   }
]
```

## VERSIONS

* **1.0.0** / nov. 2019 — Version initiale
* **1.0.2** / oct. 2020 — Mode non-partenaire
* **1.0.5** / jan. 2021 — Bug d'affichage pour les partenaires sur les revues
  qu'ils ne possèdent pas
* **1.0.8** / sep. 2002 — Pour version récente de Koha

## LICENCE

This software is copyright (c) 2022 by Tamil s.a.r.l..

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.


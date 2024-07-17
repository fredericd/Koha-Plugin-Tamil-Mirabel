# Plugin Koha ⇄ Mir@bel

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

Le plugin Koha ⇄ Mir@bal permet à un Partenaire de Mir@bel qui gère son
Catalogue de bibliothèque dans le SIGB Koha de faire remonter dans son OPAC Koha
les informations de la base de connaissances Mir@bel. Ces échanges sont réalisés
au moyens des [Service Web](https://reseau-mirabel.info/api) de Mir@bel.

Les informations Mir@bel apparaissent à l'OPAC à deux endroits :

1. **Liste des revues** — Une URL de l'OPAC affiche la liste de toutes les
   revues du partenaire avec pour chaque revue ses points d'accès signalés dans
   Mir@bel.
2. **Liste des accès** — À l'OPAC et en PRO, dans la page de détail d'une
   notice bibliographique et la page de résultat d'une recherche, les accès
   Mir@bel aux ressources sont affichés.

Pour les établissements non-partenaires Mir@bel, il est possible d'utiliser le
plugin. Seule la liste des accès sera affichée sur les pages détail/résultat en
OPAC/PRO.

## Installation

**Activation des plugins** — Si ce n'est pas déjà fait, dans Koha, activez les
plugins. Demandez à votre prestataire Koha de le faire, ou bien vérifiez les
points suivants :

* Dans `koha-conf.xml`, activez les plugins.
* Dans le fichier de configuration d'Apache, définissez l'alias `/plugins`. 
* Activez la préférence système `UseKohaPlugins` pour les Koha avant la version
  20.05. 

**▼ TÉLÉCHARGEMENT ▼** — Récupérez sur le site [Tamil](https://www.tamil.fr)
l'archive du plugin **[Koha ⇄
Mir@bel](https://www.tamil.fr/download/koha-plugin-tamil-mirabel-2.0.0.kpz)**.

**Installation** — Dans l'interface pro de Koha, allez dans Outils > Outils de
Plugins. Cliquez sur Télécharger un plugin. Choisissez l'archive téléchargée à
l'étape précédente. Cliquez sur Télécharger.

**Configuration** — Dans les Outils de plugins, vous voyez le plugin *Koha ⇄
Mir@bel*. Cliquez sur Actions > Configurer. Il faudra saisir un _ID Partenaire_
Mir@bel valide pour activer les fonctionnalités avancées du plugin.

## Configuration

### Accès à Mir@bel

Dans cette section de la configration, on spécifie un lien à Mir@bel et ses
services web.

- **Site Web** : L'URL du site public de Mir@bel.
- **Services web** : L'URL des services web.
- **Timeout** : La durée en seconde de la mise en cache des informations
  retrouvées dans Mir@bel. Cela permet de limiter le nombre de requêtes
  envoyées à Mir@bel. Pour une mise en cache d'une journée, entrez la valeur
  `86400`. Dans la phase de test du paramétrage du plugin, il est préférable de
  fixer un délai de cache très court, de `10` secondes par exmple.

### Partenaire Mir@bel

Ces éléments de configuration sont facultatifs. Ils permettent de récupérer
dans Mir@bel des informations qui ne sont disponibles que pour les
_partenaires_ de Mir@bel.

- **ID Partenaire** : Un identifiant numérique.
- **Clé privée** : Une clé qui est passée aux services web Mir@bel.

### Affichage des accès

L'affichage dans Koha des accès aux ressources Mir@bel est paramétré dans cette
section, ainsi qu'au moyen des feuilles de style XSL de Koha.

- **Emplacement** — Les accès sont affichés à l'OPAC et en PRO, à la fois sur
  la page de résultat d'une recherche et sur la page de détail d'une
  notice biblio. On choisit d'afficher ou non les accès sur ces pages.

- **Sans date / avec date** — On peut choisir les paramètres d'affichage des
  accès en fonction du type de notice Koha : périodique, extrait, ouvrage d'une
  collection. Pour certains de ces types, on peut extraire la date et s'en
  servir pour filtrer les accès. Généralement, les notices **sans date** sont
  des notices de revues ou de titre de périodique, tandis que les notices
  **avec date** (en 100 ou 210/214) sont des notices d'articles, d'extraits de
  périodique, d'ouvrage d'une collection.

- **XSL** — Les feuilles de style XSL de Koha doivent être modifiées pour
  présenter au plugin Koha ⇄ Mir@bel des ISSN de revue à rechercher dans
  Mir@bel. Par exemple, pour afficher des accès Mir@bel sur la page de résultat
  de l'OPAC, il faut à la fois activer la fonctionnalité en configuration du
  plugin et modifier la feuille XSL de la page de résultat de l'OPAC.

#### Paramètres par emplacement

Il y a un huit emplacements où afficher les accès Mir@bel : OPAC ou PRO / page
de résultat ou de détail / sans date ou avec date. Pour chaque emplacement, on
choisit les paramètres suivants :

- **Activer** — Activer l'affichage des accès à un emplacement donné.

- **Mode** — Le template d'affichage par défaut propose deux modes d'affichage
  des accès : en tableau ou en liste.

- **Revue** — Une revue peut avoir changé de nom au cours de son existance. On
  peut choisir d'afficher les accès correspondant au titre de la revue signalée
  dans Koha ou d'afficher les accès de tous les titres de la revue.

- **Exclure** — On peut choisir d'exclure de l'affichage des accès en fonction
  de leur contenu et de leur diffusion.

  - **contenu** : C'est le type de contenu de l'accès. Il y quatre valeurs
    disponibles : Intégral, Sommaire, Indexation et Résumé. On peut ainsi
    exclure par exemple de l'affichage sur la page de résultat de l'OPAC, pour
    les notices avec date (extraits ou ouvrages de collection), les accès
    _Sommaire_ et _Indexation_.
  - **diffusion** : C'est le type de diffusion où la modalité d'accès à la
    ressource. Quatre valeurs disponibles : libre, restreint, abonné,
    possession.

  Le paramètre **Exclure** est une liste de critères d'exclusion, séparés par
  des virgules. Un critère combine un contenu, éventuellement associé à une
  diffusion.

  Quelques exemples :

  - `Sommaire,Résumé` : Ne pas afficher les contenus de type Sommaire et
    Résumé.
  - `Sommaire,Intégral-restreint,Résumé-libre` : Ne pas afficher les contenus
    de type Sommaire, Texte intégral avec diffusion restreinte et Résumé avec
    diffusion libre.

- **Cacher** — On peut masquer l'affichage de certaines informations en mode
  Liste.  On peut cacher : contenu (Intégral/Résumé, etc.) / diffusion
  (libre/restreint). Par exemple pour ne pas afficher contenu et diffusion,
  saisir :

  ```
  contenu,diffusion
  ```

- **Date** — Pour les emplacements des notices Koha avec date (extrait par
  exemple), on peut choisir de filtrer les accès pour ne montrer que ceux dont
  l'intervalle de dates correspond à la date de la ressource Koha.

### Feuille de style XSL

Le plugin affiche les accès aux revues si la page de résultat d'une recherche
ou la page de détail d'une notice contient des issn encadrés dans des balises
de cette forme:

```html
<div class="mirabel-issn" style="display:none;" issn="1234-5678" />
<div class="mirabel-issn" style="display:none;" issn="1234-5678" date="2020" />
```

Cette balise doit être générée par vos feuilles de style XSL, OPAC/PRO,
résultat/détail. Les accès Mir@bel seront affichés à l'endroit où vous aurez
placé cette balise.

Par exemple, pour une revue :

```xml
<xsl:if test="marc:datafield[@tag=011]">
  <span class="mirabel-issn" style="display:none;">
    <xsl:attribute name="issn">
      <xsl:value-of select="marc:datafield[@tag=011]/marc:subfield[@code='a']"/>
    </xsl:attribute>
  </span>
</xsl:if>
```

Ou pour un article avec date :

```xml
<xsl:if test="marc:datafield[@tag=461]/marc:subfield[@code='x']">
  <span class="mirabel-issn" style="display:none;">
    <xsl:attribute name="issn">
      <xsl:value-of select="marc:datafield[@tag=461]/marc:subfield[@code='x']"/>
    </xsl:attribute>
    <xsl:attribute name="date">
      <xsl:if test="marc:datafield[@tag=100]/marc:subfield[@code='a']">
        <xsl:value-of select="substring(marc:datafield[@tag=100]/marc:subfield[@code='a'],10,4)"/>
      </xsl:if>
    </xsl:attribute>
  </span>
</xsl:if>
```

Ou pour une collection avec ISSN en 225 ou 410 :

```xml
<xsl:if test="marc:datafield[@tag=410]/marc:subfield[@code='x'] or marc:datafield[@tag=225]/marc:subfield[@code='x']">
  <span class="mirabel-issn" style="display:nonee;">
    <xsl:attribute name="issn">
      <xsl:choose>
        <xsl:when test="marc:datafield[@tag=410]/marc:subfield[@code='x']">
          <xsl:value-of select="marc:datafield[@tag=410]/marc:subfield[@code='x']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="marc:datafield[@tag=225]/marc:subfield[@code='x']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="date">
      <xsl:if test="marc:datafield[@tag=100]/marc:subfield[@code='a']">
        <xsl:value-of select="substring(marc:datafield[@tag=100]/marc:subfield[@code='a'],10,4)"/>
      </xsl:if>
    </xsl:attribute>
  </span>
</xsl:if>
```

### Templates

Il y a un template d'affichage pour l'affichage des **accès** et un autre pour
l'affichage de la liste des **revues**. Vous pouvez modifier les templates
fournis par défaut. Le système de traitement de template est le même que celui
utilisé dans Koha : [Template Toolkit](http://www.template-toolkit.org).

#### Accès

Le plugin Mir@bel envoie au template deux variables, `conf` et  `acces`. La
variable `conf` contient les paramètes de l'emplacement de l'accès. Par
exemple, `conf.mode` contient `tableau` ou `liste`. La variable `acces`
contient les accès Mir@bel :

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

#### Liste des revues

La liste des revues gérées dans Koha pour lesquelles des accès en ligne sont
proposés via Mir@bel est accessible à cette URL :

```
<OPAC_KOHA>/cgi-bin/koha/opac-main.pl?mirabel=liste
```

Créez un lien vers cette URL sur la page d'Accueil de votre OPAC. Par exemple :

```html
<a href="/cgi-bin/koha/opac-main.pl?mirabel=liste">Nos revues accessibles en ligne</a>
```


Le plugin Koha ⇄ Mir@el envoie au template une variable contenant un tableau
de revue, contenant un tableau de titres ordonnés du plus récent au plus
ancien.

Par exemple :

```json
[
   [
      {
         "titre" : "'Ilu : revista de ciencias de las religiones",
         "datefin" : null,
         "url_revue_mirabel" : "https://reseau-mirabel.info/revue/12020",
         "url" : "https://revistas.ucm.es/index.php/ILUR",
         "sigle" : null,
         "bouquetpartenaire" : null,
         "datedebut" : "1995",
         "revueid" : 12020,
         "liens" : [
            "https://www.latindex.org/latindex/ficha/8529",
            "https://kanalregister.hkdir.no/publiseringskanaler/erihplus/periodical/info.action?id=482909",
            "http://road.issn.org/issn/1988-3269",
            "https://miar.ub.edu/issn/1135-4712",
            "https://ezb.ur.de/searchres.phtml?lang=en&jq_type1=IS&jq_term1=1135-4712",
            "https://www.scopus.com/sourceid/5700168416",
            "https://explore.openalex.org/works?sort=cited_by_count:desc&filter=primary_location.source.id:S4210230912",
            "https://mjl.clarivate.com/cgi-bin/jrnlst/jlresults.cgi?PC=MASTER&ISSN=1135-4712"
         ],
         "issns" : [
            {
               "statut" : "valide",
               "support" : "papier",
               "sudocppn" : "036319236",
               "worldcatocn" : 481944929,
               "sudocnoholding" : false,
               "issn" : "1135-4712",
               "issnl" : "1135-4712",
               "bnfark" : "cb39254927g"
            },
            {
               "issnl" : "1135-4712",
               "support" : "electronique",
               "issn" : "1988-3269",
               "sudocnoholding" : false,
               "sudocppn" : "118363220",
               "statut" : "valide"
            }
         ],
         "id" : "15482",
         "periodicite" : "annuel",
         "prefixe" : null,
         "acces" : [
            {
               "ressourceid" : 13,
               "diffusion" : "possession",
               "urlproxy" : "http://inshs.bib.cnrs.fr/login?qurl=https%3A%2F%2Fdialnet.unirioja.es%2Fservlet%2Frevista%3Fcodigo%3D690",
               "ressourcesigle" : "",
               "id" : 34893,
               "url" : "https://dialnet.unirioja.es/servlet/revista?codigo=690",
               "datedebut" : "1995",
               "ressource" : "Dialnet",
               "lacunaire" : false,
               "identifiantpartenaire" : "492284",
               "numerodebut" : "no 0",
               "selection" : false,
               "titreid" : 15482,
               "contenu" : "Résumé"
            },
            {...

```

## TECHNIQUE

Ce plugin est développé grâce aux services web de la plateforme Mir@bel dont
voici la documentation :

https://reseau-mirabel.info/api

Le cœur de Mir@bel est une base de données de type relationnel, avec un schéma
arborescent à trois niveaux : Revue > Titre > Accès.

```
                                     +----------------+
                 +-------------+     |    acces       |
+----------+     |    titre    |     +----------------+
|  revue   |     +-------------+     | id             |
+----------| 1-n | id          |---->| titreid        |
| id       |---->| revueid     | 1-n | ressourceid    |
| dermodif |     | titre       |     | contenu        |
| derverif |     | datedebut   |     | diffusion      |
+----------+     | datefin     |     | nodebut        |
                 | url         |     | nofin          |
                 | periodicite |     | datedebut      |
                 | editeurs    |     | datefin        |
                 | langues     |     | url            |
                 | issns       |     | urlproxy       |
                 | prefixe     |     | ressource      |
                 | sigle       |     | ressourcesigle |
                 +-------------+     +----------------+
```

## VERSIONS

* **1.0.0** / nov. 2019 — Version initiale
* **1.0.2** / oct. 2020 — Mode non-partenaire
* **1.0.5** / jan. 2021 — Bug d'affichage pour les partenaires sur les revues
  qu'ils ne possèdent pas
* **1.0.8** / sep. 2022 — Pour version récente de Koha
* **1.0.9** / jui. 2023 — Liste OPAC des titres > 1000
* **2.0.0** / jui. 2024 — Affichage page de résultat. Templates paramétrables.
  Filtrage/masquage. Affichage pour notices non revues avec filtrage par date.


## LICENCE

This software is copyright (c) 2024 by Tamil s.a.r.l..

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.


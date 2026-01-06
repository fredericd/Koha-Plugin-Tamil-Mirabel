#!/usr/bin/perl

use Modern::Perl;
use lib ".";
use Koha::Plugin::Tamil::Mirabel;

my $metadata = $Koha::Plugin::Tamil::Mirabel::metadata;
my $file = $metadata->{canonicalname} . '-' . $metadata->{version} . '.kpz';
system "zip -r $file ./Koha";
say "Copier README.md vers wordpress:/var/www/tamil/src/doc/mirabel.md";
say "Copier $file vers wordpress:/var/www/download/";
say "Lancer la mise à jour tamil.fr : gatsby build";

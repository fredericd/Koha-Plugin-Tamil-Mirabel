#!/usr/bin/perl

use Modern::Perl;
use lib ".";
use Koha::Plugin::Tamil::Mirabel;

my $metadata = $Koha::Plugin::Tamil::Mirabel::metadata;
my $file = $metadata->{canonicalname} . '-' . $metadata->{version} . '.kpz';
system "zip -r $file ./Koha";
system "scp README.md st16:tamil-gatsby/src/doc/mirabel.md";
system "scp $file st16:download/";
say "Lancer la mise à jour tamil.fr : gatsby build";

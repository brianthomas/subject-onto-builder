#!/usr/bin/perl -w
use WWW::Wikipedia;

my $wiki = WWW::Wikipedia->new(follow_redirects => 'false');
my $term = 'astrophotography';
my $result = $wiki->search( $term);
if ( $result->text() ) { print "Has Text:",$result->text(),"\n"; }
#print STDERR "",scalar $result->related(), " related results found\n";

# list any related items we can look up 
#print join( "\n", $result->related() );

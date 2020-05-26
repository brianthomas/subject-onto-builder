#!/usr/bin/perl

package IVOA::Ontology::Subject::FilterConcept;
 
use AstroSemantics::AstroDictionary;
#use IVOA::Ontology::WikipediaSearch;
#use WWW::Wikipedia;
use WordNet::QueryData;

my $FILTER_OUT_BAD = 1;
my $DEBUG = 0;
my $REPORT = 0;

my $WORDNET_DICTIONARY_LOCATION = "/usr/share/wordnet-3.0/dict/";
my $WIKIPEDIA_ENGINE = 'IVOA::Ontology::WikipediaSearch';

# set this to 'undef' to prevent use
sub setReportProgress { $REPORT = shift; }
sub setWordNetDictionaryLocation { $WORDNET_DICTIONARY_LOCATION = shift; } 
sub setWikipediaEngine { $WIKIPEDIA_ENGINE = shift; }
sub setDebug { $DEBUG = shift; }
sub setFilterOutBad { $FILTER_OUT_BAD = shift; }

#
# Filter concepts based on a check of the AstroDictionary,
# WordNet and the Wikipedia. IF the concept does not exist in either,
# then it is filtered out as a 'bad' concept. Alternatively,
# the filtering may be reversed by setting FILTER_OUT_BAD == 0
# so that only the 'bad' concepts are kept (this is good for
# debugging).
#
# The default behavior is to keep only the 'good' concepts.
#
sub filter {
  my (@concepts_to_filter) = @_;

  my $wiki;
  if (defined $WIKIPEDIA_ENGINE) {
     eval "require $WIKIPEDIA_ENGINE";
     $wiki = $WIKIPEDIA_ENGINE->new(); #follow_redirects => 'true');
  }

  my $wn;
  if ($WORDNET_DICTIONARY_LOCATION)
  {
     $wn = WordNet::QueryData->new($WORDNET_DICTIONARY_LOCATION);
  } else {
     print "WORDNET filtering disabled\n" if $DEBUG;
  } 

  my @filtered_concepts;
  foreach my $concept (@concepts_to_filter) 
  {

     $concept =~ s/^ //g; $concept =~ s/ $//g;
     $concept =~ s/^\_//; 
     chomp $concept;

     print STDERR "Check concept:[$concept]" if $REPORT; 

     # First pass, check the AstroDictionary..
     my $term = AstroSemantics::AstroDictionary::_get_id($concept);
     my @results = AstroSemantics::AstroDictionary::getHypernyms($term);

     # NOT in the AstroDictionary? Try wordnet.. 
     if (scalar @results == 0 && defined $wn)
     {
       my $term = $concept; $term =~ s/\_/ /g;
       print STDERR "check wordnet for term:[$term]\n" if $DEBUG;
       my @synset = $wn->querySense("$term");
       if (scalar @synset > 0) {
          push @results, @synset;
       }
     }

     # NOT in the AstroDictionary or WordNet? Try the Wiki.. 
     if (scalar @results == 0 && defined $wiki) 
     {

       my $wiki_term = $concept; $wiki_term =~ s/\_/ /g;
       print STDERR "check wiki [$wiki] for term:[$wiki_term]\n" if $DEBUG;
       my $wres = $wiki->search($wiki_term);

       if ( defined $wres && (my $text = $wres->text())) 
       { 
         if ($text !~ m/There\s*were\s*no\s*results\s*matching\s*the\s*query/) { 
           # print STDERR "WIKI: Has Text",$text,"\n" if $DEBUG; 
           push @results, $wres->text();
         }
       }
       #print STDERR "ERROR: ",$wiki->error(),"\n" if $wiki->error();

     }

     print STDERR " got ",scalar @results," hits\n" if $REPORT || $DEBUG; 

     if ($FILTER_OUT_BAD) {
        push @filtered_concepts, $concept if scalar @results > 0;
     } else {
        push @filtered_concepts, $concept unless scalar @results > 0;
     }

  }

  return @filtered_concepts;

}

1;

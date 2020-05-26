#!/usr/bin/perl -w

use WordNet::QueryData;

my $wn = WordNet::QueryData->new("/usr/share/wordnet-3.0/dict/");
#my $wn = WordNet::QueryData->new( noload => 1);

#print "query(cat): ", join(", ", $wn->querySense("cat")), "\n";

$PRINT_IN_WORDNET = 0;

# search wordnet to see if there is any term
# which it contains (e.g. filter out 'jargon'
# and ackcronyms we don't expect to match without
# a technical dictionary) from the subject terms
open(FILE, "$ARGV[0]");
my $nrof_terms = 0;
my $nrof_terms_in_wordnet = 0;
foreach my $term (<FILE>) {
  chomp $term;
  #print "Synset ($term): ", join(", ", $wn->querySense("$term")), "\n";
  my @synset = $wn->querySense("$term");
  if (scalar @synset > 0) {
    $nrof_terms_in_wordnet += 1;
    print STDOUT $term,"\n" if $PRINT_IN_WORDNET;
  }
  else 
  {
    print STDOUT $term,"\n" unless $PRINT_IN_WORDNET;
  }
  $nrof_terms += 1;
}

print STDERR "NROF TERMS MatchedWordNet/Total : [",$nrof_terms_in_wordnet,"/",$nrof_terms,"]\n";


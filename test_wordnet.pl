#!/usr/bin/perl -w

use WordNet::QueryData;

my $wn = WordNet::QueryData->new("/usr/share/wordnet-3.0/dict/");
#my $wn = WordNet::QueryData->new( noload => 1);


print "QueryWOrd(cat#n#7): ", join(", ", $wn->queryWord("cat#n","also")), "\n";
print "Synset: ", join(", ", $wn->querySense("star#n", "syns")), "\n";
print "Synset: ", join(", ", $wn->querySense("cat#n#7", "syns")), "\n";
#print "Synset (cat#n): ", join(", ", $wn->querySense("cat#n", "syns")), "\n";
#print "Synset: ", join(", ", $wn->querySense("wideband#a", "syns")), "\n";

#print "query(cat#n#1): ", join(", ", $wn->querySense("cat")), "\n";
print "Hyponyms(cat#n#1): ", join(", ", $wn->querySense("cat#n#1", "hypo")), "\n";
print "Hyponums(cat#n#1): ", join(", ", $wn->querySense("cat#n#1", "hypos")), "\n";
print "Hypernyms(cat#n#1): ", join(", ", $wn->querySense("cat#n#1", "hypes")), "\n";
print "hasInstance(cat#n#1): ", join(", ", $wn->querySense("cat#n#1", "hasi")), "\n";
print "Member of Domain(cat#n#1): ", join(", ", $wn->querySense("cat#n#1", "domn")), "\n";
print "Holonyms(cat#n#1): ", join(", ", $wn->querySense("cat#n#1", "holo")), "\n";

#print "Parts of Speech (run): ", join(", ", $wn->querySense("run")), "\n";
#print "Senses (run#v): ", join(", ", $wn->querySense("run#v")), "\n";
print "Forms (lay down#v): ", join(", ", $wn->validForms("lay down#v")), "\n";
print "Forms (cat#n): ", join(", ", $wn->validForms("cat#n")), "\n";
#print "Noun count: ", scalar($wn->listAllWords("noun")), "\n";
#print "Antonyms (dark#n#1): ", join(", ", $wn->queryWord("dark#n#1", "ants")), "\n";

foreach my $syn ($wn->querySense("star#n", "syns")) {
   print "Glossary($syn): ", join(", ", $wn->querySense($syn, "glos")), "\n";
   print "Hyponyms($syn): ", join(", ", $wn->querySense($syn, "hypo")), "\n";
   print "Hypernyms($syn): ", join(", ", $wn->querySense($syn, "hypes")), "\n";
}

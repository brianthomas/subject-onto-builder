
#!/usr/bin/perl -w

#use WWW::Wikipedia;
use IVOA::Ontology::FilterConcept;

FilterConcept::setDebug(0);
FilterConcept::setReportProgress(1);
#FilterConcept::setWikipediaEngine('WWW::Wikipedia');
FilterConcept::setWikipediaEngine('IVOA::Ontology::WikipediaSearch');
#FilterConcept::setFilterOutBad(0);

die "$0 <tokens_tofilter_file>" unless $#ARGV > -1; 

open (FILE, $ARGV[0]); @input_concepts = <FILE>; close FILE; 
foreach my $concept (FilterConcept::filter(@input_concepts)) { print $concept,"\n"; }


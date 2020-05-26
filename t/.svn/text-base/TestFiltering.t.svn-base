use Test::More;

  require_ok ('IVOA::Ontology::Subject::FilterConcept');

  #IVOA::Ontology::FilterConcept::setDebug(1);
  IVOA::Ontology::Subject::FilterConcept::setWikipediaEngine('t::MockWikipediaSearch');

  #TEST 1: try to find a non-existing term
  my @expected;
  ok(eq_array(filter_concepts("not a term we have"), @expected));

  #TEST 2: try to find an existing term
  push @expected, "cataclysmic binary";
  ok(eq_array(filter_concepts("cataclysmic binary"), @expected));

  #TEST 3: lets disable wiki search
  IVOA::Ontology::Subject::FilterConcept::setWikipediaEngine(undef);
  @expected = ();
  ok(eq_array(filter_concepts("cataclysmic binary"), @expected));

  #TEST 4: try using IVOA::OntologyWikipediaSearch
  IVOA::Ontology::Subject::FilterConcept::setWikipediaEngine('IVOA::Ontology::Subject::WikipediaSearch');
  push @expected, "cataclysmic binary";
  ok(eq_array(filter_concepts("cataclysmic binary"), @expected));
   
  done_testing();

sub filter_concepts { return IVOA::Ontology::Subject::FilterConcept::filter(@_); }

1;

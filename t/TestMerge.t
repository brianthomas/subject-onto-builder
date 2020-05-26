use Test::More;
use t::TestUtils;

  require_ok ('IVOA::Ontology::Subject::MergeTool');

  #TestUtils::setDebug(1);
  IVOA::Ontology::Subject::MergeTool::setDebug(0);
  IVOA::Ontology::Subject::MergeTool::setReport(0);
  &IVOA::Ontology::Subject::MergeTool::setAllowPartialMatchedTerms(0);
  &IVOA::Ontology::Subject::MergeTool::setAllowSynonymMatchedTerms(0);
  &IVOA::Ontology::Subject::MergeTool::setRecordUnMatchedTerms(0);

sub _testMerge ($$$) 
{
  my ($input, $merge, $expected_output) = @_;

  # open input flat ontology and the donor ontology

  my $PARSER = XML::LibXML->new();
  my $base = $PARSER->parse_file($input);
  my $donor = $PARSER->parse_file($merge);
 
  my $actual_doc = IVOA::Ontology::Subject::MergeTool::merge_ontologies($donor, $base);

#  open(RESULT, ">result.owl"); print RESULT $actual_doc->toString(1); close RESULT;
#  local $/=undef;
#  open (EXPECTED, "t/result.owl"); my $expected = <EXPECTED>; close EXPECTED;

  my $expected_doc = $PARSER->parse_file($expected_output);

  my $test_success = &TestUtils::compare_nodes($actual_doc->documentElement(), $expected_doc->documentElement(), "");
  print STDERR &TestUtils::getErrorMsg() if !$test_success;

  ok($test_success, "expected merged document for ".$input);

}

  _testMerge("t/subject_flat.owl", "resources/IVOAT.owl", "t/merge_subject_flat.owl"); 

  &IVOA::Ontology::Subject::MergeTool::setAllowSynonymMatchedTerms(1);
  _testMerge("t/roqi_cds_cat.owl", "resources/IVOAT.owl", "t/merge_cds_cat.owl"); 

  done_testing();

1;

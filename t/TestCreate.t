use Test::More;

  require_ok ('IVOA::Ontology::Subject::CreateOntology');

  open (INPUT, "t/subjects_tokenized_filtered"); my @input_subjects = <INPUT>; close INPUT;
  my $actual = IVOA::Ontology::Subject::CreateOntology::create(@input_subjects);
  #open (OUTPUT, ">test_flat.owl"); print OUTPUT $actual_document; close OUTPUT;

  local $/=undef;
  open (EXPECTED, "t/test_flat.owl"); my $expected = <EXPECTED>; close EXPECTED;

  is($expected, $actual);

  done_testing();

1;

use List::MoreUtils qw/uniq/;
use Test::More;

  require_ok ('IVOA::Ontology::Subject::Tokenizer');

  IVOA::Ontology::Subject::Tokenizer::setSplitDashedTerms(0);

  open(FILE, "t/subjects_raw");
  my @list = <FILE>;
  my @subjects = uniq sort { lc($a) cmp lc($b) } IVOA::Ontology::Subject::Tokenizer::tokenize(@list);
  close FILE;

#print STDERR join "\n", @subjects, "\n";

  IVOA::Ontology::Subject::Tokenizer::setReport(0);

  open (EXPECTED, "t/subjects_tokenized2");
  #my @expected = <EXPECTED>;
  my @expected = uniq sort { lc($a) cmp lc($b) } <EXPECTED>;
  close EXPECTED;

  my $nr = 0;
  foreach my $item (@expected) {
    chomp $item;
    #print STDERR "Expected:$item Actual:",$subjects[$nr],"\n";
    die "failed on $item" unless is($subjects[$nr], $item);
    $nr++;
  }

  #ok(eq_array(@expected, @subjects));

  done_testing();

1;

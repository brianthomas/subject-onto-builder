#!/usr/bin/perl -w

use AstroInformatics::Tokenizer;
use AstroInformatics::AstroDictionary;
 
my $NROF_SYNONYMS = 0;
my $REPORT = 1;
AstroInformatics::Tokenizer::setReportStats($REPORT);
#AstroInformatics::Tokenizer::setChatty(1);
#AstroInformatics::Tokenizer::setDebug(1);


  my %subjects = &AstroInformatics::Tokenizer::run_on_file($ARGV[0]);
  
  foreach my $subject (keys %subjects) { 
     print STDOUT &checkSynonym($subject)."\n"; 
  }
  
  print STDERR "There were $NROF_SYNONYMS found\n" if $REPORT;

  #foreach my $str_count (keys %subjects) { $counts{int $str_count} = $str_count; }
  #  #foreach my $count ( sort {$a <=> $b} keys %counts) { foreach $s (@{$subjects{$count}}) { print $s, " "; } print " ($count)\n"; } 

exit 0;
  
sub checkSynonym ($) {
  my ($word) = @_;
  
  my $syn = AstroInformatics::AstroDictionary::getSynonym($word);
  if (defined $syn) {
       $NROF_SYNONYMS += 1;
       return $syn;
  }
  
  return $word;

}

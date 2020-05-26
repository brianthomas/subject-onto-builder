#!/usr/bin/perl -w

package IVOA::Ontology::Subject::Tokenizer;

use AstroSemantics::Tokenizer;
use AstroSemantics::AstroDictionary;
 
my $CHATTY = 0;
my $DEBUG = 0;
my $REPORT = 0;
my $SPLIT_DASHED_TERMS = 0;
my $NROF_SYNONYMS = 0;

sub setSplitDashedTerms{ $SPLIT_DASHED_TERMS = shift; }
sub setReport { $REPORT = shift; }
sub setDebug { $DEBUG = shift; }
sub setChatty { $CHATTY = shift; }

sub tokenize {
  my (@list) = @_;

  AstroSemantics::Tokenizer::setReportStats($REPORT);
  AstroSemantics::Tokenizer::setSplitDashedTerms($SPLIT_DASHED_TERMS);
  AstroSemantics::Tokenizer::setChatty($CHATTY);
  AstroSemantics::Tokenizer::setDebug($DEBUG);

  my %subjects = &AstroSemantics::Tokenizer::run_on_list(@list);
  
  my @tokenized_subjects;
  foreach my $subject (keys %subjects) 
  { 
     push @tokenized_subjects, &checkSynonym($subject);
  }
  
  print STDERR "There were $NROF_SYNONYMS synonyms found\n" if $REPORT;

  #foreach my $str_count (keys %subjects) { $counts{int $str_count} = $str_count; }
  #foreach my $count ( sort {$a <=> $b} keys %counts) { foreach $s (@{$subjects{$count}}) { print $s, " "; } print " ($count)\n"; } 

  return @tokenized_subjects;
}

sub checkSynonym ($) {
  my ($word) = @_;
  
  my @syns = AstroSemantics::AstroDictionary::getSynonyms($word);
  if (defined $syns[0]) {
       $NROF_SYNONYMS += $#syns + 1;
  }
  else {
     push @syns, $word;
  }
  return @syns;
}

1;

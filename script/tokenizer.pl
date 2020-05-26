#!/usr/bin/perl -w

use IVOA::Ontology::Subject::Tokenizer;
 

IVOA::Ontology::Subject::Tokenizer::setReport(1);

die "$0 <textfile>" unless $#ARGV > -1;

open (FILE, $ARGV[0]);
my @list = <FILE>;
foreach my $token (IVOA::Ontology::Subject::Tokenizer::tokenize(@list)) { print $token,"\n"; }
close FILE;


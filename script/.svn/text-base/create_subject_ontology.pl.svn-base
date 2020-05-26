#!/usr/bin/perl -w

use IVOA::Ontology::Subject::CreateOntology;

open (INPUT, $ARGV[0]); 
my @input_subjects = <INPUT>; 
close INPUT;

print &IVOA::Ontology::Subject::CreateOntology::create(@input_subjects);


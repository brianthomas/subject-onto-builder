#!/usr/bin/perl -w

BEGIN {

         @INC = ("./lib/", @INC);
#         print "PATH:", join ',', @INC, "\n";
      }

use IVOA::Ontology::Subject::MergeTool;

die "usage: $0 <donoronto> <baseonto> > <mergedonto>\n" unless ($#ARGV > 0);

my $donor_file= $ARGV[0];
die "Donor ontology file $donor_file not found\n" unless (-e $donor_file);
my $base_file= $ARGV[1];
die "Base ontology file $base_file not found\n" unless (-e $base_file);

# open both ontologies
my $PARSER = XML::LibXML->new();
my $donor = $PARSER->parse_file($donor_file); 
my $base = $PARSER->parse_file($base_file); 

&IVOA::Ontology::Subject::MergeTool::setReport(1);
&IVOA::Ontology::Subject::MergeTool::setDebug(1);
&IVOA::Ontology::Subject::MergeTool::setAllowPartialMatchedTerms(0);
&IVOA::Ontology::Subject::MergeTool::setAllowSynonymMatchedTerms(1);
&IVOA::Ontology::Subject::MergeTool::setRecordUnMatchedTerms(1);

my $doc = IVOA::Ontology::Subject::MergeTool::merge_ontologies($donor, $base);
print $doc->toString(2);



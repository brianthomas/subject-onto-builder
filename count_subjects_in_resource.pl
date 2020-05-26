#!/usr/bin/perl -w
# trim down the copious metadata in the ontology 
# so that we only see subject (owl:Class) metadata

use XML::LibXML();
use XML::LibXML::Common qw(:libxml);
use ROQI::Util;

my $REGISTRY_NS_URI = 'http://www.ivoa.net/xml/RegistryInterface/v1.0';
my $RESOURCE_TAGNAME = 'Resource';

my $DEBUG = 1;

my %SUBJECTS;
my $resource_count = 0;

foreach my $file (@ARGV) 
{
   # parse/load the file
   print STDERR "Doing : $file\n" if $DEBUG;
   my $PARSER = XML::LibXML->new();
   my $doc = $PARSER->parse_file($file);
   my $rootNode = $doc->documentElement();
   foreach my $resource_node (&Util::find_elements($rootNode, $REGISTRY_NS_URI, $RESOURCE_TAGNAME)) {
      $resource_count += 1;
      &getSubjects($resource_node);
   }

   # second pass in case they didnt specify the namespace properly
   foreach my $resource_node (&Util::find_elements($rootNode, '', $RESOURCE_TAGNAME)) {
      $resource_count += 1;
      &getSubjects($resource_node);
   }
}

my @subjects = keys %SUBJECTS;
foreach my $s (@subjects) { print STDERR "$s\n"; }
print STDERR "Got ",($#subjects+1)," subjects from ",$resource_count," resources\n";

#
# S U B R O U T I N E S
#
sub getSubjects($) {
   my ($resource_node) = @_;

  # print STDERR "getSUBJECTs called\n";
   foreach my $subject_node ($resource_node->getElementsByTagName("subject"))
   {
         my $stext = &Util::find_text($subject_node);
         if (defined $stext) { 
            $SUBJECTS{$stext} = 0 unless (defined $SUBJECTS{$stext});
            $SUBJECTS{$stext} += 1; 
         } 
   }
}

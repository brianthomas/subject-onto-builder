#!/usr/bin/perl -w

use XML::LibXML();
use XML::LibXML::Common qw(:libxml);

# A program to build a subject ontology from a list of subjects
#  

my $SUBJECT_NS_URI = 'http://net.ivoa/vocabulary/1.0/registrySubject';
#my $UCD_NS_URI = 'http://www.ivoa.net/Document/WD/vocabularies/20080222/UCD';
#my $REGISTRY_ONTO_NS_URI = 'http://www.ivoa.net/owl/registryResource.owl';

my $RDF_NS_URI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

my $ADD_SUBJECT_CLASS = 0;
my $DEBUG = 0;

#
# B E G I N
# 
 
die "usage: $0 <subjectlist> > <outputontology>\n" unless ($#ARGV > -1);

my $subject_file= $ARGV[0];
die "Subjects file $subject_file not found\n" unless (-e $subject_file);

# open a new file, and create the onto
#my $PARSER = XML::LibXML->new();

my $Ontology_doc = &print_preamble(XML::LibXML::Document->new('1.0','UTF-8'));

open (SUBJECTS, "$subject_file");
foreach my $subject (<SUBJECTS>) {
   #print STDERR "$subject ";
   chomp $subject;
   &createSubjectNode($Ontology_doc, $subject, $subject);
}
&print_postamble($Ontology_doc);

print STDOUT $Ontology_doc->toString(1);
exit;

#
# S U B R O U T I N E S
#
 
sub addElement ($$$) {
  my ($doc, $p, $tag) = @_;

  my $new_node = $doc->createElement($tag);
  $p->addChild($new_node);

  return $new_node;
}

sub createSubjectNode($$$$) {
    my ($doc, $id, $label) = @_;

    print STDERR " create Subject:[$id]\n" if $DEBUG;

    my $subject_node = $doc->createElement("owl:Class");
    $subject_node->setAttribute("rdf:ID", $id);
    $doc->documentElement()->addChild($subject_node);

    my $label_node = addElement($doc,$subject_node,"rdfs:label");
    $label_node->addChild($doc->createTextNode($label));

    if ($ADD_SUBJECT_CLASS) {
       my $sub_subclass_elem = addElement($doc,$subject_node,"rdfs:subClassOf");
       $sub_subclass_elem->setAttribute("rdf:resource","#Subject");
    }

   return $subject_node;
}


sub print_preamble ($) {
   my ($doc) = @_;

   my $root = $doc->createElement("rdf:RDF");
   $doc->setDocumentElement($root);
   $root->setAttribute('xmlns:rdf', $RDF_NS_URI);
   $root->setAttribute('xmlns:owl', 'http://www.w3.org/2002/07/owl#');
   $root->setAttribute('xmlns:rdfs','http://www.w3.org/2000/01/rdf-schema#');
   $root->setAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema#');
   $root->setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance#');
   $root->setAttribute('xmlns:ivoat', "http://net.ivoa/vocabulary/1.0/IVOAT#");
#   $root->setAttribute('xmlns:ucd', $UCD_NS_URI."#");
#   $root->setAttribute('xmlns:r', $REGISTRY_ONTO_NS_URI."#");
   $root->setAttribute('xmlns', $SUBJECT_NS_URI.'#');
   $root->setAttribute('xml:base', $SUBJECT_NS_URI);

   my $onto_decl = addElement($doc,$root,"owl:Ontology");
   $onto_decl->setAttribute("rdf:about","");

#   my $onto_import_ucd = addElement($doc,$onto_decl, "owl:imports");
#   $onto_import_ucd->setAttribute("rdf:resource",$UCD_NS_URI);

#   my $onto_import_reg = addElement($doc,$onto_decl,"owl:imports");
#   $onto_import_reg->setAttribute("rdf:resource",$REGISTRY_ONTO_NS_URI);

   my $onto_comment = addElement($doc,$onto_decl,"rdfs:comment");
   $onto_comment->setAttribute("rdf:datatype","http://www.w3.org/2001/XMLSchema#string");
   my $onto_comment_txt = $doc->createTextNode("Registry Subject Ontology. Generated by $0");
   $onto_comment->addChild($onto_comment_txt);

   if ($ADD_SUBJECT_CLASS) { 
     my $subject_decl = addElement($doc,$root,"owl:Class");
     $subject_decl->setAttribute("rdf:ID","Subject");
   }

   #print STDERR $doc->toString(1);
   return $doc;
}

sub print_postamble ($) {
   my ($doc) = @_;
#   my $root = $doc->documentElement();
#   $root->addChild( createObjPropNode($doc,"hasAvailableUcd", $UCD_NS_URI."#UCD","#Subject"));
#   $root->addChild( createObjPropNode($doc,"hasUCD", $UCD_NS_URI."#UCD",$REGISTRY_ONTO_NS_URI."#Resource"));
#   $root->addChild( createObjPropNode($doc,"hasResource", $REGISTRY_ONTO_NS_URI."#Resource", "#Subject"));
}
 

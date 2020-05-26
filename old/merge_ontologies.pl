#!/usr/bin/perl -w

use XML::LibXML();
use XML::LibXML::Common qw(:libxml);
use AstroInformatics::TextProcessing;
use AstroInformatics::AstroDictionary;

my %base_elems;
my %donor_elems;
my %HAS_MERGED_CLASS;
my $DEBUG = 1;

# A program to merge 2 ontologies. The first one specified will
# be borrowed from to add to the second one.
#

  die "usage: $0 <donoronto> <baseonto> > <mergedonto>\n" unless ($#ARGV > 0);

  my $donor_file= $ARGV[0];
  die "Donor ontology file $donor_file not found\n" unless (-e $donor_file);
  my $base_file= $ARGV[1];
  die "Base ontology file $base_file not found\n" unless (-e $base_file);

  # open both ontologies
  my $PARSER = XML::LibXML->new();

  my $donor = $PARSER->parse_file($donor_file); 
  my $base = $PARSER->parse_file($base_file); 

  %base_elems = &createClassElementHash($base);
  %donor_elems = &createClassElementHash($donor);

  &merge_ontologies($donor, $base);

  print STDOUT $base->toString(1);

  exit 0;

#
# S U B R O U T I N E S
#

sub createClassElementHash($) {
  my ($doc) = @_;
  my %element_hash;
  foreach my $elem ($doc->documentElement->getElementsByTagName("owl:Class")) {
     my $id = formatId($elem->getAttribute("rdf:ID"));
     $element_hash{$id} = $elem;
  }
  return %element_hash;
}

sub merge_ontologies($$) {
  my ($donorDoc, $baseDoc) = @_;

  my $nrof_matched_term = 0;
  foreach my $base_elem_id (keys %base_elems) 
  {

    print STDERR "Try matching concept id:$base_elem_id\n" if $DEBUG;

    # simple match on name comparison
    if (exists $donor_elems{$base_elem_id}) {
      print STDERR "MATCHED node in donor ontology id:$base_elem_id\n" if $DEBUG;
      $nrof_matched_term += 1;
      &mergeClassIntoDoc($baseDoc, $donor_elems{$base_elem_id}, $base_elem_id);
    }
    else
    {

        my @hyponyms = AstroInformatics::AstroDictionary::getHypernyms($base_elem_id);
        foreach my $test_parent_id (@hyponyms) 
        {
           my $test_id = formatId($test_parent_id); 
           if (exists $donor_elems{$test_id}) {
              print STDERR "GOT A partial match for based on parent id:$test_id\n" if $DEBUG;
              $nrof_matched_term += 0.5;
              # add the donor element to the document as a subclass of
              # the node
              &mergeClassIntoDoc($baseDoc, $donor_elems{$test_id}, $test_id); 
              addSubclassNode($baseDoc, $base_elems{$base_elem_id}, $test_id);
              last;
           }
        } 
    }
  }

  print STDERR "Matched $nrof_matched_term terms out of ",scalar keys %base_elems,"\n";

  # finally, grab all of the Properties
  # and copy them in the base onto from the donor
  foreach my $prop ($donorDoc->documentElement->getElementsByTagName("ObjectProperty")) 
  {
     $baseDoc->documentElement->addChild($prop);
  }
  foreach my $prop ($donorDoc->documentElement->getElementsByTagName("DatatypeProperty")) 
  {
     $baseDoc->documentElement->addChild($prop);
  }

}

sub mergeClassIntoDoc($$$) 
{
  my ($baseDoc, $merge_elem, $merge_id ) = @_;

  # lets prevent possible infinite recursion..
#  print STDERR " MERGE Class id:$merge_id\n" if $DEBUG;
  return if (exists $HAS_MERGED_CLASS{$merge_id});
  $HAS_MERGED_CLASS{$merge_id} = 1;

  $merge_elem->setAttribute("rdf:ID", $merge_id);
  my @subclsIds = &mergeNodeIntoDoc($baseDoc, $merge_elem, $base_elems{$merge_id});
  foreach my $id (@subclsIds) 
  {
     &mergeClassIntoDoc($baseDoc, $donor_elems{$id}, $id); 
  }

}


sub mergeNodeIntoDoc ($$$$) 
{
  my ($baseDoc, $donor_elem, $base_elem) = @_; 

  my $new_elem;
  if (defined $base_elem) {
     $new_elem = $baseDoc->documentElement->replaceChild($donor_elem, $base_elem); 
#     print STDERR " Replace new Node $new_elem\n";
  } else {
     $new_elem = $baseDoc->documentElement->addChild($donor_elem); 
#     print STDERR " Create new Node $new_elem\n";
  } 

  # now check the declared sub-classes, if any, and make sure
  # they too get added in

  my @subClsIds;
  foreach my $subclsElement ($donor_elem->getElementsByTagName("rdfs:subClassOf")) {
     my $id = $subclsElement->getAttribute("rdf:resource");
     if (defined $id) {
        $id = formatId(substr($subclsElement->getAttribute("rdf:resource"), 1));
        print STDERR " Got sub-class node in donor ontology id:$id\n";
        push @subClsIds, $id;
        $subclsElement->setAttribute("rdf:resource", "#".$id);
     }
  } 

  return @subClsIds;
}

sub addSubclassNode($$) {
  my ($doc, $cls_elem, $subclsId) = @_;

  my $subclsNode = $doc->createElement("rdfs:subClassOf");
  $subclsNode->setAttribute("rdf:resource", "#".$subclsId);
  $cls_elem->addChild($subclsNode);

}

sub formatId ($) {
  my ($id) = @_;
  if ($id =~ m/^([\W|\w]+)\s*of\s*([\W|\w]+)$/) {
     $id = &AstroInformatics::TextProcessing::make_singular($2) . $1;
  }
  $id =~ s/_//g;
  $id =~ s/\-//g;
  return &AstroInformatics::TextProcessing::make_singular(lc $id);
}



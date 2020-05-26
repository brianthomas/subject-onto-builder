#!/usr/bin/perl -w

package IVOA::Ontology::Subject::MergeTool;

use XML::LibXML();
use XML::LibXML::Common qw(:libxml);
use AstroSemantics::TextProcessing;
use AstroSemantics::AstroDictionary;
use WordNet::QueryData;
use Algorithm::FastPermute ('permute');


my %BASE_ELEMS;
my %DONOR_ELEMS;
my %HAS_MERGED_CLASS;
my $WORDNET;

my $WORDNET_DICTIONARY_LOCATION = "/usr/share/wordnet-3.0/dict/";
sub setWordNetDictionaryLocation { $WORDNET_DICTIONARY_LOCATION = shift; }

my $REPORT = 0;
sub setReport { $REPORT = shift; }

my $DEBUG = 0;
sub setDebug { $DEBUG = shift; }

my $ALLOW_PARTIAL_MATCHED_TERMS = 0;
sub setAllowPartialMatchedTerms { $ALLOW_PARTIAL_MATCHED_TERMS = shift; }

my $ALLOW_SYNONYM_MATCHED_TERMS = 0;
sub setAllowSynonymMatchedTerms { $ALLOW_SYNONYM_MATCHED_TERMS = shift; }

my $RECORD_UNMATCHED_TERMS = 0;
sub setRecordUnMatchedTerms { $RECORD_UNMATCHED_TERMS = shift; }

# A program to merge 2 ontologies. The first one specified will
# be borrowed from to add to the second one.
sub merge_ontologies {
  my ($donor, $base) = @_;

  if ($WORDNET_DICTIONARY_LOCATION)
  {
     $WORDNET = WordNet::QueryData->new($WORDNET_DICTIONARY_LOCATION);
  } else {
     print STDERR "WORDNET synonym matching disabled\n"; 
  }

  %BASE_ELEMS = &_createClassElementHash($base);
  %DONOR_ELEMS = &_createClassElementHash($donor);

  &_do_merge($donor, $base);

  return $base;
}

sub _getElementRawId($) {
  my ($elem) = @_;

  my $term = $elem->getAttribute("rdf:ID");

  # No rdf:ID attribute?? fall back to 
  # rdf:about
  if (!$term) {
    $term = $elem->getAttribute("rdf:about");
  }
     
  # No rdf:about attribute?? fall back to 
  # the rdf:ID try to use rdf:label child elements
  if (!$term) {
    foreach my $lbl ($elem->getElementsByTagName("rdfs:label"))
    {
     		$term = $lbl->textContent();
     		last unless (!$term);
    }
  }

  $term =~ s/^#//;
  $term =~ s/^\s+//;
  $term =~ s/\s+$//;
  return $term;

}

sub _createClassElementHash($) {
  my ($doc) = @_;

  my %element_hash;
  foreach my $elem ($doc->documentElement->getElementsByTagName("owl:Class")) 
  {
     my $term = _getElementRawId($elem);
     my $id = _getClassId($term);

     my %info;
     $info{'id'} = $id;
     $info{'elem'} = $elem;
     $info{'term'} = $term;
     $element_hash{_getLookupId($id)} = \%info;
  }
  return %element_hash;
}

sub _addElementToBaseHash ($) {
  my ($elem) = @_;

  my $term = _getElementRawId($elem);
  my $id = _getClassId($term);

  my %info;

  $info{'id'} = $id;
  $info{'elem'} = $elem;
  $info{'term'} = $term;
  $BASE_ELEMS{_getLookupId($id)} = \%info;

}

sub _get_synonyms ($) {
  my ($word) = @_;

  print STDERR "  check syns for word:[$word]\n" if $DEBUG;

  my %synonyms;
  my $term = $word; 
  $term =~ s/\_/ /g;

  return unless defined $term && $term ne "";

  if (defined $WORDNET)
  {
       my @synset = $WORDNET->querySense("$term");
       if (scalar @synset > 0) {
          foreach my $syn (@synset) {
             if ($syn =~ m/#n$/) { # take only nouns
               $syn =~ s/#n$//;
               $synonyms{$syn} = 1 unless $syn eq $word;
             }
          }
       }
  }

  $term =~ s/ //g;
#print STDERR "CHECK ASTRODICT for synonym to $term ($word)\n";
  foreach my $syn (&AstroSemantics::AstroDictionary::getSynonyms($term))
  {
#print STDERR "GOT ASTRODICT SYN: $syn\n";
      $synonyms{$syn} = 1 unless $syn eq $word;
  }

  # return keys 
  return keys %synonyms;
}

sub _get_id($) {
   my ($hash_ref) = @_;
   return undef if !defined $hash_ref;
   my %hash = %$hash_ref;
   my $id = $hash{'id'};
   return $id;
}

sub _get_element ($) {
   my ($hash_ref) = @_;

   return undef if !defined $hash_ref;
   my %hash = %$hash_ref;
   my $elem = $hash{'elem'};
   return $elem;
}

sub _get_term($) {
   my ($hash_ref) = @_;

   return undef if !defined $hash_ref;
   my %hash = %$hash_ref;
   my $term = $hash{'term'};
   return $term;
}

sub _do_merge($$) {
  my ($donorDoc, $baseDoc) = @_;

  my @unmatchedTerms;
  my $nrof_non_phrase_terms = 0;
  my $nrof_matched_term = 0;
  foreach my $base_elem_id (keys %BASE_ELEMS) 
  {

    # skip phrase (compound subject) terms 
    if ($base_elem_id =~ m/\./)
    {
       #print STDERR " * Skipping PHRASE term : $base_elem_id (its already decomposed elsewhere) \n" if $DEBUG && $REPORT;
       next;
    }

    # We dont try to merge 'subject', which is our top class in the hierarchy
    next if ($base_elem_id eq 'subject');

    $nrof_non_phrase_terms += 1;

    if((my $matched = &_tryToMerge($baseDoc, $base_elem_id)))
    {
       $nrof_matched_term += $matched;
    }
    else {
      push @unmatchedTerms, &_get_term($BASE_ELEMS{$base_elem_id});
    }
   
  }

  print STDERR "Matched $nrof_matched_term terms out of ",$nrof_non_phrase_terms,"\n" if $REPORT;

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

  if ($RECORD_UNMATCHED_TERMS) {
     print STDERR "UNMATCHED TERMS in base onto:\n";
     foreach my $term (sort @unmatchedTerms) 
     {
        print STDERR $term, "\n" unless ($term =~ m/\./); 
     }
  }

}

sub _tryToMerge ($$) 
{
    my ($baseDoc, $base_elem_id) = @_;

    my $term = &_get_term($BASE_ELEMS{$base_elem_id});

    return unless defined $base_elem_id && defined $term; 

    print STDERR "Try matching concept id:$base_elem_id ($term)\n" if $DEBUG or $REPORT;

    # try to do a 'direct match' first
    print STDERR " * TRY direct match term \n" if $DEBUG;
    if (&_tryToMatchTerm($baseDoc, $base_elem_id, $term)) {
       return 1;
    }

    # Hmm. failed, try straight synonym match, if desired 
    if ($ALLOW_SYNONYM_MATCHED_TERMS) {
      my @synonyms = _get_synonyms ($term);
      print STDERR "SYNONYMS[$term]: ", join ',', @synonyms, "\n" if $DEBUG;
      foreach my $synterm (@synonyms) {
          if (&_tryToMatchTerm($baseDoc, $base_elem_id, $synterm)) {
            return 1;
          }
       }
    }

    # Now try matching by messing with formatted text
    if ($term =~ m/--/)
    {
        print STDERR " * TRY splitting and matching -- term \n" if $DEBUG;
        my @subterms = split '--', $term;
        if ((my $matched = _tryMatchingWithMultipleTerms($baseDoc, $base_elem_id, \@subterms)))
        {
           return $matched;
        }
    }
    elsif ($term =~ m/\_/)
    {
        print STDERR " * TRY splitting and matching term with underscore (space)\n" if $DEBUG;
        my @subterms = split '_', $term;
        if ((my $matched = _tryMatchingWithMultipleTerms($baseDoc, $base_elem_id, \@subterms)))
        {
           return $matched;
        }
    }

    return 0;
}

sub _get_synonyms_for_subterms ($) 
{
    my $ref = shift;
    my @subterms = @{$ref};
  
    my %synonyms;
    foreach my $subterm (@subterms) {
      my @vals = _get_synonyms ($subterm);
      $synonyms{$subterm} = \@vals; 
    }

    my @permutations;
    permute {
      push @permutations, join ' ', @subterms;
    } @subterms; 

    my @synterms;
    foreach my $permutation (@permutations) {
#      print STDERR "PERMUATION: $permutation\n";
      my @terms = split ' ',$permutation;
      for (my $i = 0; $i <= $#terms; $i++) 
      {
        
         my $pre = ($i > 0) ? join ' ', @terms[0 .. ($i-1)] : "";
         my $post = ($i != $#terms) ? join ' ', @terms[($i+1).. $#terms] : "";
         my $term = $terms[$i];
#         print STDERR "Permutation [$i]: pre:$pre term:$term post:$post \n"; 
         foreach my $syn (@{$synonyms{$term}}) {
             next unless defined $syn;
             my $synterm = $pre.' '.$syn.' '.$post;
             $synterm =~ s/^\s+//; $synterm =~ s/\s+$//;
             push @synterms, $synterm;
         }
      }
      
    }

    return @synterms;
}

sub _tryToMatchTerm($) 
{
   my ($baseDoc, $base_elem_id, $match_term) = @_;

   my $match_id = _getLookupId($match_term);
   print STDERR "  tryToMatch base_id:[$base_elem_id] match_id:[$match_id] match_term:[$match_term]\n" if $DEBUG or $REPORT;

   if (exists $DONOR_ELEMS{$match_id}) {
      print STDERR " * MATCHED node in donor ontology donor:$match_id (base:$base_elem_id) \n" if $DEBUG or $REPORT;
      &_mergeClassIntoDoc($baseDoc, $match_id, $base_elem_id);
      return $match_id;
   }

   return;
}

sub _tryMatchingWithMultipleTerms($) 
{
    my ($baseDoc, $base_elem_id, $subterms_ref) = @_;

    my @subterms = @{$subterms_ref};

    # Try all permutations of combining subterms 
    # upon the first match, bail out
    my @permutations;
    permute {
      my $term = join ' ', @subterms;
      push @permutations, $term;
    } @subterms;

    foreach my $term (@permutations) {
      print STDERR " Try to match permuted term:[$term] base:($base_elem_id)\n" if $DEBUG;
      if (&_tryToMatchTerm($baseDoc, $base_elem_id, $term)) { return 1; }
    }

    if ($ALLOW_SYNONYM_MATCHED_TERMS) {
      #my @synonyms = _get_synonyms_for_subterms($subterms_ref);
      my @synonyms;
      foreach my $term (@permutations) {
         push @synonyms, _get_synonyms($term);
      }
      print STDERR " SYNONYMS[$base_elem_id]: ", join ',', @synonyms, "\n" if $DEBUG;
      foreach my $synterm (@synonyms) {
         if (&_tryToMatchTerm($baseDoc, $base_elem_id, $synterm)) { 
            return 1; 
         }
      }
    }

    return 0 unless $ALLOW_PARTIAL_MATCHED_TERMS;

    # if we didnt match, try matching partial (sub)terms 
    # IF we match, then we will consider the matched term
    # a PARENT class. Lets not get too crazy here, we limit
    # ourselves to dropping one of the subterms from the term 
    #
    my @partial_permutations;
    permute {
      my $term = join ' ', @subterms[0..$#subterms-1];
      push @partial_permutations, $term;
    } @subterms;

    my $got_partial_term = 0;
    foreach my $term (@partial_permutations) {
       my $partial_id = _getClassId($term);
       if (exists $DONOR_ELEMS{$partial_id}) {
         print STDERR " *   Partial MATCH to $term \n" if $DEBUG;
         # in this case, the donor element is a PARENT of the base document
         # element, and we have to treat it differently (its not a merge..)
         my (@subclsOfIds) = &_mergeClassIntoDocAsParentOfBase($baseDoc, $partial_id, _getClassId($base_elem_id));
         $got_partial_term += $#subterms/($#subterms+1);
       }
    }

    if ($got_partial_term > 0) { return $got_partial_term; }

    return 0;
}

# used for partial matching
sub _mergeClassIntoDocAsParentOfBase($$$) 
{
  my ($baseDoc, $parent_id, $orig_id ) = @_;

  return if (exists $HAS_MERGED_CLASS{$orig_id});
  $HAS_MERGED_CLASS{$orig_id} = 1;

  print STDERR "   MERGE PARENT OF class id:$orig_id parent id: $parent_id\n" if $DEBUG;

  my $base_elem = _get_element($BASE_ELEMS{$orig_id});
  &_addSubclassOfNode($baseDoc, $base_elem, $parent_id);

  # add the new parent
  my ($parent_elem, @subClsOfIds) = _mergeNodeIntoDoc ($baseDoc, $parent_id, undef);

  # add in subclass nodes to the document
  foreach my $parent_id (@subClsOfIds)
  {
     my $id = _resolve_id($parent_id);
     &_mergeClassIntoDoc($baseDoc, $id, $id);
     &_addSubclassOfNode($baseDoc, $parent_elem, $id);
  }

  # remove this from being a child of subject
  if ((my $subjSubclsOf = _isSubclsOfSubjectAndOtherClasses($parent_elem))) {
     print STDERR "   * dropping (1) $orig_id from direct descendant of #subject\n" if $DEBUG;
     $parent_elem->removeChild($subjSubclsOf);
  }
#  elsif ($#subClsOfIds == -1) {
#     print STDERR "   * add subject(1) as subclassOf $parent_id\n";
#     _addSubclassOfNode($baseDoc, $parent_elem, "subject");
#  }

  return @subClsOfIds;
}

sub _mergeClassIntoDoc($$$) 
{
  my ($baseDoc, $merge_id, $orig_id ) = @_;

  my $merge_elem = _get_element($DONOR_ELEMS{$merge_id});
  
  # lets prevent possible infinite recursion..
#  return if (!defined $merge_elem);
  return if (exists $HAS_MERGED_CLASS{$orig_id} or !defined $merge_elem);
  $HAS_MERGED_CLASS{$orig_id} = 1;

  print STDERR "   MERGE Class Into Doc id:$orig_id\n" if $DEBUG;

  $merge_elem->setAttribute("rdf:ID", $orig_id);
  my $base_elem = _get_element($BASE_ELEMS{$orig_id});
  my ($new_elem, @subclsOfIds) = &_mergeNodeIntoDoc($baseDoc, $merge_id, $base_elem);

  # merge in any subclassOf (parent) nodes to the document
  foreach my $parent_id (@subclsOfIds) 
  {
     my $id = _resolve_id($parent_id);
     &_mergeClassIntoDoc($baseDoc, $id, $id); 
     &_addSubclassOfNode($baseDoc, $new_elem, $id);
  }

  # IF base element is a sub-class of subject
  # we drop it now, assuming that it has subclasses
  if ((my $subjSubclsOf = _isSubclsOfSubjectAndOtherClasses($new_elem))) {
        print STDERR "   * dropping (2) $orig_id from direct descendant of #subject\n" if $DEBUG;
        $new_elem->removeChild($subjSubclsOf); 
  } 
  elsif ($#subclsOfIds == -1) { # no parent classes? then its a child of subject 
        print STDERR "   * add subject(2) as subclassOf $orig_id\n" if $DEBUG;
        _addSubclassOfNode($baseDoc, $new_elem, "subject");
  }

}

sub _resolve_id ($) 
{
  my ($id) = @_;

  my @check;
  push @check, $id;
  push @check, _get_synonyms ($id);
  foreach my $check_id (@check) 
  {
     my $lookup_id = _getLookupId($check_id); 
     if (exists $BASE_ELEMS{$lookup_id})
     {
         return _get_id ($BASE_ELEMS{$lookup_id});
     }
  }

  return $id;
}

sub _mergeNodeIntoDoc ($$$) 
{
  my ($baseDoc, $donor_id, $base_elem) = @_; 

  my $donor_elem = _get_element($DONOR_ELEMS{$donor_id});

  my $new_elem;
  if (defined $base_elem) {
     my $base_id = _getElementRawId($base_elem);
     print STDERR "         into document using existing node ($base_id)\n" if $DEBUG;
     $new_elem = $base_elem;
  } 
  else 
  {
#     my $donor_id = _getElementRawId($donor_elem);
     print STDERR "         by creating new node based on donor node ($donor_id).\n" if $DEBUG;
     #$new_elem = $baseDoc->documentElement->addChild($donor_elem); 
     $new_elem = $baseDoc->createElement("owl:Class"); 
     $new_elem->setAttribute("rdf:ID", $donor_id); 
     $new_elem = $baseDoc->documentElement->addChild($new_elem); 
     $baseDoc->documentElement->addChild($baseDoc->createTextNode("\n"));
     _addElementToBaseHash ($new_elem);
  } 

  # now add in label elements
  foreach my $labelElement ($donor_elem->getElementsByTagName("rdfs:label")) 
  {
     $new_elem->appendChild($labelElement);
  }

  # now check the declared parent classes, if any, and make sure
  # they too get added in
  my @subClsOfIds;
  foreach my $subclsElementOf ($donor_elem->getElementsByTagName("rdfs:subClassOf"))
  {
     my $id = $subclsElementOf->getAttribute("rdf:resource");
     if (defined $id) {
        $id = _getClassId(substr($subclsElementOf->getAttribute("rdf:resource"), 1));
        if ($id ne "subject") {
          print STDERR "    -> Got parent node in donor ontology id:$id\n" if $DEBUG;
          push @subClsOfIds, $id;
#          $subclsElementOf->setAttribute("rdf:resource", "#".$id);
#          $new_elem->appendChild($subclsElementOf);
       }
     }
  }

  return ($new_elem, @subClsOfIds);
}


sub _isSubclsOfSubjectAndOtherClasses ($) {
  my ($elem) = @_;

  return unless defined $elem;

#  print STDERR "CHECK _isSubclassOfSubject for element id:",_getElementRawId($elem),"\n";

  my @subclsOfElems = $elem->getElementsByTagName("rdfs:subClassOf");

  # we are only concerned with the case  
  # where this element contains more than one subclassOf element
  # AND one of these is a 'subject'
  #
  return unless $#subclsOfElems > 0; 
  foreach my $subclsOfElement (@subclsOfElems)
  {
     my $id = $subclsOfElement->getAttribute("rdf:resource");
     if (defined $id)
     {
       if($id eq '#subject') 
       {
          return $subclsOfElement;
       } 
     } 
     else 
     {
        my $id = _getElementRawId($elem);
        print STDERR "Warning: got an rdfs:subClassOf element, but no rdf:resource attribute for id:$id, skipping\n";
     }
  }

  return;
}

sub _addSubclassOfNode($$$) {
  my ($doc, $cls_elem, $subclsId) = @_;

  my $id = _getElementRawId($cls_elem);
  print STDERR "     ADD $id subclassOf $subclsId\n" if $DEBUG and $subclsId ne 'subject';

  my $subclsNode = $doc->createElement("rdfs:subClassOf");
  $subclsNode->setAttribute("rdf:resource", "#".$subclsId);
  $cls_elem->addChild($subclsNode);

}

sub _getLookupId ($) {
  my ($val) = @_;

  $val =~ s/\_//g;
  my $id = _getClassId($val); 

  return $id;

}

sub _getClassId ($) {
  my ($id) = @_;

  my $val = &AstroSemantics::TextProcessing::getClassId($id);
  # print STDERR "_getClassId($id => $val)\n";# if $DEBUG; 

  return $val;
}

1;

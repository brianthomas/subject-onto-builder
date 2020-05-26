
package TestUtils;

use ROQI::Util;
use XML::LibXML();
use XML::LibXML::Common qw(:libxml);

my $DEBUG = 0;
my $ERROR_MSG = "";

my @LOG;

sub setDebug ($) { $DEBUG = shift; }

sub compare_nodes ($$$) {
  my ($node1, $node2, $indent) = @_;

  my @attributes1 = sort{$a <=> $b} ($node1->attributes());
  my @attributes2 = sort{$a <=> $b} ($node2->attributes());

  return 0 unless defined $node1 and defined $node2;

  if ($DEBUG) {
    print STDERR "$indent CHECK Node name: ".$node1->nodeName()." "._attrToString(@attributes1)."\n";
    print STDERR "$indent    VS Node name: ".$node2->nodeName()." "._attrToString(@attributes2)."\n";
    # print STDERR "CHECK:"; &dump_node($node1,$indent); print STDERR "vs:"; &dump_node($node2,$indent); 
  }

  if ($node1->nodeName() ne $node2->nodeName()) {
     _setErrorMsg("node: ".$node1->nodeName()."(".($#attributes1-1).") does not match ".$node2->nodeName()."(".($#attributes2-1).")\n");
     return 0;
  }


  if ($#attributes1 ne $#attributes2)
  {
    _setErrorMsg("NUMBER of attributes differ for node: ".$node1->nodeName()." ".($#attributes1-1)." vs ".($#attributes2-1)."\n");
    return 0;
  }

  foreach my $attr1 (@attributes1) {
     if (!&_find_matching_attribute($attr1, \@attributes2)) {
        return 0; 
     }
  } 

  if (defined $node1->textContent()) {
    my $text1 = &ROQI::Util::find_text($node2);
    my $text2 =  ROQI::Util::find_text($node1);
    if ($text1 ne $text2)
    {
       _setErrorMsg("NODE TEXT DIFFERS:$text1 vs $text2\n");
       return 0 
    }
  }

  my @children1 = $node1->childNodes(); 
  return 1 unless $#children1 >= 0;

#  my @children2 = $node2->childNodes(); 
#  if ($#children1 ne $#children2)
#  {
#      _setErrorMsg("NUMBER of child nodes differ for node: ".$node1->nodeName()." ".($#children1-1)." vs ".($#children2-1)."\n");
#      return 0;
#  }

  foreach my $child1 (@children1) 
  { 
     my $result = 0;
     next unless $child1->nodeType eq XML_ELEMENT_NODE ;
     foreach my $child2 ($node2->getChildrenByTagName($child1->nodeName()))
     {
        next unless $child2->nodeType eq XML_ELEMENT_NODE;
        if (&compare_nodes($child1, $child2, $indent."  ") == 1) { 
             $result = 1; last;
        }
     }

     if ($result == 0) { 
        _setErrorMsg("No child node matches for node: ".$node1->nodeName()."("._attrToString(@attributes1).") \n");
        return 0; 
     }
  }

  return 1; 

}

sub _attrToString ($) {
   my (@attr) = @_;

   my $str = "";
   foreach my $a (@attr) {
     $str .= $a->nodeName(). "=" . $a->value() . " ";
   }
   return $str;
}

sub _find_matching_attribute {
   my ($attr1, $attr2_list_ref) = @_;

   my @attr2_matched_attr = &_find_attributes($attr1->nodeName(), $attr2_list_ref);

   foreach my $attr2 (@attr2_matched_attr) {
     if (defined $attr2 && $attr1->value() eq $attr2->value()) {
        return 1;
     }
   }
  
   #_setErrorMsg("attribute ".$attr1->nodeName(). " value ".$attr1->value()." is not matched in 2nd document\n");
   return 0;
} 

sub getErrorMsg ($) { return $ERROR_MSG; }
sub resetErrorMsg ($) { $ERROR_MSG = ""; }

sub _setErrorMsg ($) {
   my ($msg) = @_;

   $ERROR_MSG .= $msg unless $ERROR_MSG =~ m/$msg/; 
}

sub _find_attributes {
   my ($attrName, $base_attr_list_ref) = @_;

   my @matched_attr_list; 
   my @base_attr_list = @{$base_attr_list_ref};

   foreach my $attr (@base_attr_list) {
     if ($attrName eq $attr->nodeName()) {
         push @matched_attr_list, $attr;
     }
   }

   return @matched_attr_list;
}

sub dump_node {
   my ($node, $indent) = @_;
   print STDERR "$indent<",$node->nodeName();
   foreach my $attr ($node->attributes()) { print STDERR " ",$attr->nodeName(),"=\"",$attr->value(),"\""; }
   print STDERR ">\n";
   my @children = $node->childNodes(); 
   if ($#children>-1) {
      foreach my $child (@children) { 
         dump_node($child,$indent."  ") if $child->nodeType eq XML_ELEMENT_NODE; 
      }
   }
}

1;

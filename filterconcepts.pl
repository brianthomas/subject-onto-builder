#!/usr/bin/perl
 
use AstroInformatics::AstroDictionary;
use WWW::Wikipedia;
use WordNet::QueryData;

my $wiki = WWW::Wikipedia->new(); #follow_redirects => 'true');
my $wn = WordNet::QueryData->new("/usr/share/wordnet-3.0/dict/");

my $FILTER_OUT_BAD = 1;
my $DEBUG = 1;
open (FILE, $ARGV[0]);

foreach my $concept (<FILE>) 
{

   $concept =~ s/^ //g; $concept =~ s/ $//g;
   $concept =~ s/^\_//; 
   chomp $concept;

   print STDERR "Check concept:[$concept]" if $DEBUG; 

   my $term = AstroInformatics::AstroDictionary::_get_id($concept);
   my @results = AstroInformatics::AstroDictionary::getHypernyms($term);

   if (scalar @results == 0) {

     my $term = $concept; $term =~ s/\_/ /g;
     my $wres = $wiki->search($term);

     if ( defined $wres && (my $text = $wres->text()) ) { 
#        print "Has Text",$text,"\n" if $DEBUG; 
        push @results, $wres->text();
     }
   }

   if (scalar @results == 0) {
     my $term = $concept; $term =~ s/\_/ /g;
     my @synset = $wn->querySense("$term");
     if (scalar @synset > 0) {
         push @results, @synset;
     }
   }

   print STDERR " returned ",scalar @results," results\n" if $DEBUG; 

   if ($FILTER_OUT_BAD) {
      print STDOUT $concept,"\n" if scalar @results > 0;
   } else {
      print STDOUT $concept,"\n" unless scalar @results > 0;
   }

}

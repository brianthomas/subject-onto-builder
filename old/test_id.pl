

my $Id = 'dude--is--dude--lady--dude';
my $Id2 = 'dude--lady--is';
my $Id3 = 'Star--star--cataclysmic--binary';

print STDERR "Fixed Id: ", getFixedId($Id), "\n"; 
print STDERR "Fixed Id: ", getFixedId($Id2), "\n"; 
print STDERR "Fixed Id: ", getFixedId($Id3), "\n"; 

sub getFixedId($) {
   my ($str) = @_;

   # try to insure uniqueness by using a hash  
   my %hash;
   my @keys = split '--', $str;
   #@hash{@keys} = ("") x @keys;

   #my @alphabetical = sort { lc($a) cmp lc($b) } keys %hash;
#   my @alphabetical = sort { lc($a) cmp lc($b) } @keys;
#   my @lowercase = map { lc } @alphabetical;
   my @lowercase = map { lc } @keys;
   @hash{@lowercase} = ("") x @lowercase;
   my @alphabetical = sort { lc($a) cmp lc($b) } keys %hash;

   # TODO: currently we are performance limited. When we have
   # too many terms, the program bogs down 
   #return join '-', keys %hash if (scalar keys %hash > 7);
   #return join '-', @lowercase if (scalar @lowercase > 7);
   return join '-', @alphabetical if (scalar @alphabetical > 7);
    
   my @id_keys;
   foreach my $key (@alphabetical) { 
   #foreach my $key (@lowercase) { 
      #if (!exists $IGNORE_SUBJECT{$key}) { 
      #  push @id_keys, checkSynonym($key); 
      #} 
      push @id_keys, $key; 
   }
   
   my $id = join '--', @id_keys;
   chomp $id; chomp $id;
   
   return $id;
}

sub getFixedId3($) {
   my ($str) = @_;

   my @keys = split '--', $str;
   my %hash;
   @hash{@keys} = ("") x @keys;

   my @alphabetical = sort { lc($a) cmp lc($b) } keys %hash;
   my $id = join '--', @alphabetical;
   chomp $id; chomp $id;

   return $id;
}

sub getFixedId2($) {
   my ($str) = @_;

   my @keys = split '--', $str;
   my %hash;
   @hash{@keys} = ("") x @keys;

   my $id = join '--', keys %hash;
   chomp $id; chomp $id;

   return $id;
}

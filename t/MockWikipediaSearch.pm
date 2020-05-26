
package t::MockWikipediaSearch;
use WWW::Wikipedia::Entry;

#use base qw(WWW::Wikipedia);

#use constant WIKIPEDIA_URL => 'http://%s.wikipedia.org/w/index.php?title=Special:Search&search=%s';
use constant SRC => 'http://en.wikipedia.org/w/index.php?title=item&action=raw';
#
 
sub new {
    my ( $class, %opts ) = @_;
    my $self = {};# = LWP::UserAgent->new( %opts );
    bless $self, ref( $class ) || $class;

    open(CONTENT, "t/good_content.html");
    $self->{_CONTENT} = <CONTENT>;
    close CONTENT;
    return $self;
}

sub error {
    my $self = shift;
    if ( @_ ) { $self->{ _ERROR } = shift; }
    return $self->{ _ERROR };
}

sub search {
    my ( $self, $string ) = @_;

    $self->error( undef );
    croak( "search() requires you pass in a string" ) if !defined( $string );
    my $entry;
   
    if ($string =~ m/cataclysmic binary/i) { $entry = WWW::Wikipedia::Entry->new($self->{_CONTENT}, SRC); }
    return $entry;
}

1;


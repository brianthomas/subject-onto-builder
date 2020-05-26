package IVOA::Ontology::Subject::WikipediaSearch;

use WWW::Wikipedia::Entry;

use base qw(WWW::Wikipedia);

# change search URL to pick up more concepts
use constant WIKIPEDIA_URL => 
          'http://%s.wikipedia.org/w/index.php?title=Special:Search&search=%s';
#         'http://%s.wikipedia.org/w/index.php?title=%s&action=raw';
 
# for some reason, to override the constant, I have to also copy in the
# subroutine of the base class which uses it?? Fooey
#
sub search {
    my ( $self, $string ) = @_;

    $self->error( undef );
    croak( "search() requires you pass in a string" ) if !defined( $string );

    $string = utf8::is_utf8( $string )
        ? URI::Escape::uri_escape_utf8( $string )
        : URI::Escape::uri_escape( $string );
    my $src = sprintf( WIKIPEDIA_URL, $self->language(), $string );

    my $response = $self->get( $src );
    if ( $response->is_success() ) {
        my $entry = WWW::Wikipedia::Entry->new( $response->content(), $src );

        # look for a wikipedia style redirect and process if necessary
        return $self->search( $1 )
        if $self->follow_redirects && $entry->text() =~ /^#REDIRECT ([^\r\n]+)/is;
        	return ( $entry );
    }
    else {
        $self->error( "uhoh, WWW::Wikipedia unable to contact " . $src );
        return undef;
    }
}

1;


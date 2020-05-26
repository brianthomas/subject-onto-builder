use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'IVOA::Ontology::Subject',
    license             => 'lgpl',
    dist_author         => 'Brian Thomas <bthomas@noao.edu>',
    dist_abstract       => 'false',
    build_requires => {
        'Algorithm::FastPermute' => '0.999',
        'AstroSemantics' => '1.0',
        'Test::More' => '0.94',
        'WWW::Wikipedia' => '1.99',
        'WordNet::QueryData' => '1.49',
        'XML::LibXML' => '1.70',
        'XML::LibXML::Common' => '1.70',
        'Test::More' => '0.94',
    },
);

$builder->create_build_script();

component {

    this.name = 'molliecfml';
    this.title = 'Mollie CFML';
    this.author = 'Blackbuck Software';
    this.webURL = 'https://github.com/blackbucksoftware/mollie-cfml';
    this.description = 'This module will provide you with connectivity to the Mollie API for any ColdFusion (CFML) application.';
    this.entryPoint = 'molliecfml';
    this.modelNamespace = 'molliecfml';
    this.cfmapping = 'molliecfml';
    this.dependencies = [ ];

    function configure() {
        settings = {
            key: ''
        };
    }

    function onLoad() {
        binder
            .map( 'mollie@molliecfml' )
            .to( '#moduleMapping#.mollie' )
            .asSingleton()
            .initWith( key = settings.key );
    }

}
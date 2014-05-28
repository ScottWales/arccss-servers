Analytics service
=================

Provides an elasticsearch/kibana analytics interface on the NCI cloud

Usage
-----

 * Boot/update:

    make provision

 * Connect:

    make ssh

 * Shutdown

    make shutdown

Repository Layout
-----------------

The main manifest is `manifests/site.pp`, which sets up some dependencies then
loads classes listed in Hiera. The classes in the `roles` module are the main
glue code, for instance `roles::elasticsearch` installs Elasticsearch &
Kibanaas well as sets up Apache.

External Puppet modules listed in the Puppetfile are installed using
librarian-puppet. 

Server Layout
-------------

The server runs an Elasticsearch host, protected by an Apache reverse proxy.
Kibana is available at `https://$::fqdn` with LDAP authentication, clients can
also access Elasticsearch indices through whitelisted IPs to create records.

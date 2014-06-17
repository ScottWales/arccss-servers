ARCCSS CMS Servers
==================

Available servers:

 - *puppetmaster*: Puppet provisioning control
 - *proxy*: Web proxy & load balancer
 - *downloader*: Write access to /g/data
 - *ramadda*: Ramadda/Thredds data repository interface
 - *jenkins*: Continuous integration server

Control
-------

To boot a server:

    ./cloud boot SERVER

To ssh to a server

    ./cloud ssh SERVER

To shutdown a server

    ./cloud shutdown SERVER

How it works
------------

The `cloud` script will boot an instance using nova, then connect to the server
to install puppet & related programs.

Provisioning is done by having the servers connect to the puppetmaster via
cloud-init. Bootstrapping the puppetmaster itself is done by checking out the
repository on the server & running `puppet apply`.


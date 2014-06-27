## \file    modules/roles/manifests/jenkins.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#
#  Copyright 2014 ARC Centre of Excellence for Climate Systems Science
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

class roles::jenkins {
  include roles::webserver
  include apache::mod::headers
  include ::jenkins
  include ::docker

  $vhost = $::fqdn

  file {'/var/lib/jenkins/config.xml':
  }

  #   # Docker base image for jobs
  #   docker::image {'evarga/jenkins-slave':
  #   }

  apache::vhost {'jenkins-redirect':
    servername      => $vhost,
    port            => '80',
    redirect_status => 'permanent',
    redirect_dest   => "https://${vhost}/",
    docroot         => '/var/www/null',
  }

  apache::vhost {'jenkins-ssl':
    servername      => $vhost,
    port            => '443',
    ssl             => true,
    custom_fragment =>
      'AllowEncodedSlashes On
       RequestHeader set X-Forwarded-Proto "https"
       RequestHeader set X-Forwarded-Port "443"',
    proxy_pass      => [
      {'path'       => '/',
      'url'         => 'http://localhost:8080/',} ],
    docroot         => '/var/www/html',
  }

  augeas {'jenkins base':
    lens    => 'Xml.lns',
    incl    => '/var/lib/jenkins/config.xml',
    context => '/files/var/lib/jenkins/config.xml/hudson',
    changes => [
      'set numExecutors/#text "0"',
      'set useSecurity/#text true',
      'set securityRealm ""',
      'set clouds ""',
      'set clouds/com.nirima.jenkins.plugins.docker.DockerCloud ""',
    ],
    require => [Package['jenkins'],File['/var/lib/jenkins/config.xml']],
    notify  => Service['jenkins'],
  }

  # Configure security
  augeas {'jenkins security':
    lens    => 'Xml.lns',
    incl    => '/var/lib/jenkins/config.xml',
    context => '/files/var/lib/jenkins/config.xml/hudson/securityRealm',
    changes => [
      'set #attribute/class hudson.security.LDAPSecurityRealm',
      'set #attribute/plugin ldap@1.10.2',
      'set server/#text ldap://sfldap0.anu.edu.au',
      'set rootDN/#text dc=apac,dc=edu,dc=au',
      'set userSearchBase/#text ou=People',
      'set userSearch/#text uid={0}',
      'set groupSearchBase/#text ou=Group',
      'set disableMailAddressResolver/#text true',
    ],
    require => Augeas['jenkins base'],
    notify  => Service['jenkins'],
  }

  # Configure Docker instance generation
  augeas {'jenkins docker cloud':
    lens    => 'Xml.lns',
    incl    => '/var/lib/jenkins/config.xml',
    context => '/files/var/lib/jenkins/config.xml/hudson/clouds/com.nirima.jenkins.plugins.docker.DockerCloud',
    changes => [
      'set #attribute/plugin docker-plugin@0.3.5',
      'set name/#text Docker Sandboxes',
      'set serverUrl/#text http://127.0.0.1:4243',
      'set templates/com.nirima.jenkins.plugins.docker.DockerTemplate ""',
    ],
    require => Augeas['jenkins base'],
    notify  => Service['jenkins'],
  }

  augeas {'jenkins docker template':
    lens    => 'Xml.lns',
    incl    => '/var/lib/jenkins/config.xml',
    context => '/files/var/lib/jenkins/config.xml/hudson/clouds/com.nirima.jenkins.plugins.docker.DockerCloud/templates/com.nirima.jenkins.plugins.docker.DockerTemplate',
    changes => [
      'set image/#text jenkins-slave',
      'set labelString/#text "ubuntu docker"',
      'set credentialsId ""',
      'set dockerCommand ""',
      'set jvmOptions ""',
      'set javaPath ""',
      'set prefixStartSlaveCmd ""',
      'set suffixStartSlaveCmd ""',
      'set remoteFs/#text /home/jenkins',
      'set instanceCap/#text "4"',
      'set dnsHosts ""',
      'set dnsHosts/string/#text "8.8.8.8"',
      'set tagOnCompletion/#text false',
      'set additionalTag ""',
      'set pushOnSuccess/#text false',
      'set privileged/#text false',
    ],
    require => Augeas['jenkins docker cloud'],
    notify  => Service['jenkins'],
  }

  file {'/tmp/jenkins-dockerfile':
    ensure => present,
    source => 'puppet:///modules/roles/jenkins/Dockerfile',
  }

  exec {'docker build -t jenkins-slave - < /tmp/jenkins-dockerfile':
    path    => ['/bin','/usr/bin'],
    unless  => 'docker images | grep \'^jenkins-slave\>\'',
    require => [
      File['/tmp/jenkins-dockerfile'],
      Package['docker'],
    ]
  }

  augeas {'jenkins mail':
    lens    => 'Xml.lns',
    incl    => '/var/lib/jenkins/hudson.tasks.Mailer.xml',
    changes => [
      'set hudson.tasks.Mailer_-DescriptorImpl/defaultSuffix/#text "@anusf.anu.edu.au"',
    ],
    require => Package['jenkins'],
    notify  => Service['jenkins'],
  }

}

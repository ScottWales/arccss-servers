## \file    modules/roles/manifests/jenkins/dockerimage.pp
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

# Install the docker image
class roles::jenkins::dockerimage {
  include ::docker

  # Create a ssh key
  exec {'jenkins ssh key':
    command => "ssh-keygen -t rsa -F ${roles::jenkins::home}/.ssh/id_rsa -P ''",
    path    => ['/bin','/usr/bin'],
    creates => "${roles::jenkins::home}/.ssh/id_rsa",
  }

  # Save the dockerfile locally
  file {'/tmp/jenkins-dockerfile':
    ensure => present,
    source => 'puppet:///modules/roles/jenkins/Dockerfile',
  }
  file {'/tmp/jenkins.id_rsa.pub':
    ensure  => present,
    source  => "${roles::jenkins::home}/.ssh/id_rsa.pub",
    require => Exec['jenkins ssh key'],
  }

  # Build the image
  exec {'docker build -t jenkins-slave - < /tmp/jenkins-dockerfile':
    path    => ['/bin','/usr/bin'],
    unless  => 'docker images | grep \'^jenkins-slave\>\'',
    require => [
      File[
        '/tmp/jenkins-dockerfile',
        '/tmp/jenkins.id_rsa.pub'
      ],
      Package['docker'],
    ]
  }

}
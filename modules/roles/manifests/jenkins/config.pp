## \file    modules/roles/manifests/jenkins/config.pp
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

# Some basic config for bootstrapping
class roles::jenkins::config {

  file {"${roles::jenkins::home}/config.xml":
    owner   => 'jenkins',
    require => Package['jenkins'],
  }

  augeas {'jenkins base':
    lens    => 'Xml.lns',
    incl    => "${roles::jenkins::home}/config.xml",
    context => "/files/${roles::jenkins::home}/config.xml",
    changes => [
      'set hudson ""',
      'set hudson/numExecutors/#text "0"',
      'set hudson/useSecurity/#text true',
      'set hudson/securityRealm ""',
    ],
    require => File["${roles::jenkins::home}/config.xml"],
    notify  => Service['jenkins'],
  }

  # Configure security
  augeas {'jenkins security':
    lens    => 'Xml.lns',
    incl    => "${roles::jenkins::home}/config.xml",
    context => "/files/${roles::jenkins::home}/config.xml/hudson/securityRealm",
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

  file {"${roles::jenkins::home}/hudson.tasks.Mailer.xml":
    owner   => 'jenkins',
    require => Package['jenkins'],
  }
  augeas {'jenkins mail':
    lens    => 'Xml.lns',
    incl    => "${roles::jenkins::home}/hudson.tasks.Mailer.xml",
    changes => [
      'set hudson.tasks.Mailer_-DescriptorImpl/defaultSuffix/#text "@anusf.anu.edu.au"',
    ],
    require => File["${roles::jenkins::home}/hudson.tasks.Mailer.xml"],
    notify  => Service['jenkins'],
  }
}

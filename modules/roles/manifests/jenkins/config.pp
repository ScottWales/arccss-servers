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

# Some basic config for bootstrapping, updates to these will be saved through
# backups

class roles::jenkins::config {

  file {"${roles::jenkins::home}/config.xml":
    ensure  => present,
    replace => false,
    owner   => 'jenkins',
    group   => 'jenkins',
    content => template('roles/jenkins/config.xml.erb'),
    require => Package['jenkins'],
    notify  => Service['jenkins'],
  }
  file {"${roles::jenkins::home}/hudson.tasks.Mailer.xml":
    ensure  => present,
    replace => false,
    owner   => 'jenkins',
    group   => 'jenkins',
    content => template('roles/jenkins/hudson.tasks.Mailer.xml.erb'),
    require => Package['jenkins'],
    notify  => Service['jenkins'],
  }
}

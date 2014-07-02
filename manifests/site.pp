# Puppet node definition
#
# This sets up a VM using the configuration settings found in the 'hieradata'
# directory.

node default {

  # Include default classes
  include roles::common

  # Set up firewall dependencies
  Firewall {
    require => Class['roles::firewall::pre'],
    before  => Class['roles::firewall::post'],
  }

  # Package pre-requisites
  package {'rubygems':}
  Package['rubygems'] -> Package<|provider == gem|>
  package {'python-pip':}
  Package['python-pip'] -> Package<|provider == pip|>

  package {'wget': }

  # Include classes listed in 'hieradata' files
  # These should mainly be from the 'roles' module, the roles sets up
  # dependencies from external modules (e.g. install a Jenkins instance then
  # configure an Apache vhost pointing to it)
  hiera_include('classes')

  # Silence deprecation warning
  # https://ask.puppetlabs.com/question/6640
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    Package {
      allow_virtual => true,
    }
  }

}

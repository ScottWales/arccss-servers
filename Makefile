# Boot cloud nodes
#
# Specify which node using the 'HOST' variable, e.g.
#     make HOST=stats
#
# TODO: this is getting beyond what a makefile should sensibly do, look at
# other options

# Default task is to boot & provision host
all: provision

HOST      ?= 
# Openstack host key to use for root
VMKEY     := $(shell hostname)

# Openstack variables for each host
ifeq (${HOST},stats)
    VMNAME     = stats.accessdev.nci.org.au
    VMIP       = 130.56.244.74
    VMFLAVOR   = m1.small
    VMIMAGE    = centos-6.4-20130920
endif
ifeq (${HOST},jenkins)
    VMNAME     = jenkins.climate-cms.nci.org.au
    VMIP       = 130.56.244.115
    VMFLAVOR   = m1.small
    VMIMAGE    = centos-6.4-20130920
endif

# Remote connections
REMOTE     = root@${VMIP}
RSYNC      = rsync -av --rsh '${SSH}' --exclude '.*'
SSH        = ssh ${SSHFLAGS}
SSHFLAGS   = -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no

# Paths to ruby apps (installed with bundler)
BUNDLEPATH = .vendor
LINT       = bundle exec puppet-lint
PUPPET     = bundle exec puppet

# List of all puppet files for testing
PPFILES   := $(shell find . -type f -name '*.pp' ! -wholename '*/.*')

# Apply this puppet manifest on the VM
provision: boot lint validate
	${RSYNC} $$PWD/ ${REMOTE}:/etc/puppet
	${SSH} ${REMOTE} 'cd /etc/puppet && librarian-puppet install --verbose'
	${SSH} ${REMOTE} puppet apply /etc/puppet/manifests/site.pp

# Boot the VM ('if' check is so that the VM isn't booted twice)
boot:
	if ! nova list | grep '\s${VMNAME}\s'; then \
	    nova boot \
		--image ${VMIMAGE} \
		--flavor ${VMFLAVOR} \
		--key_name ${VMKEY} \
		--security_groups ssh,http \
		--poll \
		${VMNAME}; \
	    nova add-floating-ip ${VMNAME} ${VMIP}; \
	    while ! ${SSH} ${REMOTE} true; do sleep 10; done; \
	    ${SSH} ${REMOTE} yum update --assumeyes; \
	    ${SSH} ${REMOTE} rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm; \
	    ${SSH} ${REMOTE} yum install --assumeyes git puppet rsync rubygems; \
	    ${SSH} ${REMOTE} gem install librarian-puppet --no-rdoc --no-ri; \
	    ${SSH} ${REMOTE} iptables -F; \
	    ${SSH} ${REMOTE} ip6tables -F; \
	fi

shutdown:
	nova delete ${VMNAME}

ssh:
	${SSH} ${REMOTE}

# Do some basic testing of the manifest
lint: bundle
	${LINT} ${LINTFLAGS} ${PPFILES}
validate: bundle
	${PUPPET} parser validate ${PPFILES}

# Install Ruby apps
bundle: ${BUNDLEPATH}/.empty
${BUNDLEPATH}/.empty: Gemfile
	bundle install --path ${BUNDLEPATH}
	touch $@

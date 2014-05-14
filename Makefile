all: provision

VMNAME     = elastic1
VMIP       = 130.56.244.78

VMFLAVOR   = m1.small
VMIMAGE    = centos-6.4-20130920
VMKEY     := $(shell hostname)

REMOTE     = root@${VMIP}

RSYNC      = rsync -av --rsh '${SSH}' --exclude '.*'
SSH        = ssh ${SSHFLAGS}
SSHFLAGS   = -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no

BUNDLEPATH = .vendor
LINT       = bundle exec puppet-lint
PUPPET     = bundle exec puppet

PPFILES   := $(shell find . -type f -name '*.pp' ! -wholename '*/.*')

provision: boot lint validate
	${RSYNC} $$PWD/ ${REMOTE}:/etc/puppet
	${SSH} ${REMOTE} 'cd /etc/puppet && librarian-puppet install'
	${SSH} ${REMOTE} puppet apply /etc/puppet/manifests/site.pp

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
	    ${SSH} ${REMOTE} rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm; \
	    ${SSH} ${REMOTE} yum install --assumeyes puppet rsync rubygems; \
	    ${SSH} ${REMOTE} gem install librarian-puppet --no-rdoc --no-ri; \
	    ${SSH} ${REMOTE} iptables -F; \
	    ${SSH} ${REMOTE} ip6tables -F; \
	fi

shutdown:
	nova delete ${VMNAME}

ssh:
	${SSH} ${REMOTE}

lint: bundle
	${LINT} ${LINTFLAGS} ${PPFILES}

validate: bundle
	${PUPPET} parser validate ${PPFILES}

bundle: ${BUNDLEPATH}/.empty
	
${BUNDLEPATH}/.empty: Gemfile
	bundle install --path ${BUNDLEPATH}
	touch $@

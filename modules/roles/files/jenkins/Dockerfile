# Baseimage sets us up with a SSH server, init system, etc.
FROM phusion/baseimage

RUN apt-get update

# Install JDK for Jenkins
RUN apt-get install -y --no-install-recommends openjdk-7-jdk

# Install basic developer stuff
RUN apt-get install -y git subversion gcc gfortran python make libopenmpi-dev

# Create jenkins user
RUN adduser --quiet --disabled-password jenkins

# Add ssh key
ADD id_rsa.pub /tmp/id_rsa.pub
RUN mkdir -p /home/jenkins/.ssh && cat /tmp/id_rsa.pub >> /home/jenkins/.ssh/authorized_keys && chmod -R 0700 /home/jenkins/.ssh && chown -R jenkins:jenkins /home/jenkins/.ssh

# Grant sudo access
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Generate host keys
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
EXPOSE 22

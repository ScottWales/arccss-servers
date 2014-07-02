# Baseimage sets us up with a SSH server, init system, etc.
FROM phusion/baseimage

RUN apt-get update

# Install JDK for Jenkins
RUN apt-get install -y --no-install-recommends openjdk-7-jdk

# Install basic developer stuff
RUN apt-get install -y git subversion gcc gfortran python

# Create jenkins user
RUN adduser --quiet jenkins

# Add ssh key
ADD id_rsa.pub /tmp/id_rsa.pub
RUN cat /tmp/id_rsa.pub >> /home/jenkins/.ssh/authorized_keys

# Grant sudo access
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

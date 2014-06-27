FROM evarga/jenkins-slave

# Install basic developer stuff
RUN apt-get install -y git subversion gcc gfortran python

# Grant sudo access
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

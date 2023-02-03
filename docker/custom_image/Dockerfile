FROM jenkins/jenkins

# Install docker
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
#RUN usermod -a -G docker jenkins

USER jenkins

# Install the plugins 
#RUN jenkins-plugin-cli --plugins kubernetes:3845.va_9823979a_744 #Comment if using helm installation
RUN jenkins-plugin-cli --plugins blueocean:1.27.1
RUN jenkins-plugin-cli --plugins docker-plugin:1.3.0

FROM jenkins/jenkins:lts
USER root

# Docker script
RUN apt update
RUN apt install -y curl
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh ./get-docker.sh
RUN usermod -aG docker jenkins

RUN apt-get install -y uidmap

USER jenkins

RUN dockerd-rootless-setuptool.sh install

RUN jenkins-plugin-cli --plugins blueocean:1.25.5
RUN jenkins-plugin-cli --plugins credentials:1139.veb_9579fca_33b_
RUN jenkins-plugin-cli --plugins docker-workflow:1.29
RUN jenkins-plugin-cli --plugins git:4.11.3
RUN jenkins-plugin-cli --plugins kubernetes:3663.v1c1e0ec5b_650
RUN jenkins-plugin-cli --plugins docker-plugin:1.2.9
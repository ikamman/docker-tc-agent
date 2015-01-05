FROM dockerfile/java:oracle-java8

MAINTAINER Kamil Manka <kamil.manka@gmail.com>

RUN export LANGUAGE="en_US.UTF-8"
RUN echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
RUN echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

RUN apt-get -y install wget unzip
COPY setup-agent.sh /setup-agent.sh
RUN chmod +x /setup-agent.sh

CMD ["/setup-agent.sh", "run"]
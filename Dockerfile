FROM debian:jessie-backports

RUN sed -i '/jessie-updates/d' /etc/apt/sources.list
RUN sed -i '/deb.debian.org/d' /etc/apt/sources.list
RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" >> /etc/apt/sources.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN rm -rf /etc/apt/sources.list.d/*
RUN cat /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -t jessie-backports --no-install-recommends  openjdk-8-jre-headless ca-certificates-java \
    && rm -rf /var/lib/apt/lists/*
    
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

RUN apt-get -o Acquire::Check-Valid-Until=false update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools wget

ENV HADOOP_VERSION 2.6.4
ENV HADOOP_URL http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN wget "$HADOOP_URL" -P /tmp/ \
    && tar -xvf /tmp/hadoop-2.6.4.tar.gz -C /opt/ \
    && rm /tmp/hadoop-2.6.4.tar.gz \
    && ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop \
    && cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml \
    && mkdir /opt/hadoop-$HADOOP_VERSION/logs \
    && mkdir /hadoop-data \
    && rm -Rf /opt/hadoop-$HADOOP_VERSION/share/doc/hadoop

ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1

ENV USER=root
ENV PATH $HADOOP_PREFIX/bin/:$PATH

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

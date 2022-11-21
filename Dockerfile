FROM apache/james:jpa-3.7.2

RUN apt-get update && \
    apt-get -y install redsocks iptables && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

COPY redsocks.conf /
COPY entrypoint.sh /

ENTRYPOINT ["bash", "entrypoint.sh"]
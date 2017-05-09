#FROM armhf/debian:jessie
FROM resin/armv7hf-debian-qemu:latest
# Default configuration
RUN [ "cross-build-start" ]

RUN gpg \
    --keyserver hkp://ha.pool.sks-keyservers.net \
    --recv-keys 05CE15085FC09D18E99EFB22684A14CF2582E0C5

ENV INFLUXDB_VERSION 1.2.3
RUN  apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget && \
    wget -q https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_armhf.deb.asc && \
    wget -q https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_armhf.deb && \
    gpg --batch --verify influxdb_${INFLUXDB_VERSION}_armhf.deb.asc influxdb_${INFLUXDB_VERSION}_armhf.deb && \
    dpkg -i influxdb_${INFLUXDB_VERSION}_armhf.deb && \
    rm -f influxdb_${INFLUXDB_VERSION}_armhf.deb* && \
    apt-get purge --auto-remove -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
COPY influxdb.conf /etc/influxdb/influxdb.conf

# Add Tini
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /tini
RUN chmod +x /tini

RUN [ "cross-build-end" ]
# Run as mopidy user

EXPOSE 8086

VOLUME /var/lib/influxdb

ENTRYPOINT ["/tini", "--"]

CMD ["influxd"]

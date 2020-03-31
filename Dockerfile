FROM ubuntu:bionic

MAINTAINER Dan Belza <danbelza.v3@gmail.com>

RUN apt-get update && apt-get install -y \
        libxml2-dev \
        libmysqlclient-dev \
        libssh-dev \
        libssl-dev \
        autoconf \
        automake \
        build-essential \
        wget

WORKDIR /src

RUN wget http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb && \
    wget http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb && \
    dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb && \
    dpkg -i bison_2.7.1.dfsg-1_amd64.deb

RUN wget --no-check-certificate http://kannel.org/download/1.4.5/gateway-1.4.5.tar.gz && \
    tar -xzf gateway-1.4.5.tar.gz && mv gateway-1.4.5 gateway && cd gateway && \
    ./configure --prefix=/usr --with-mysql --with-mysql-dir=/var/lib/mysql \
        --enable-assertions --with-defaults=speed --enable-localtime \
        --enable-start-stop-daemon --enable-pam --disable-docs && \
    touch .depend && make depend && \
    make && make bindir=/usr install

RUN cd /src/gateway/addons/sqlbox && \
    ./configure -prefix=/usr -with-kannel-dir=/usr && \
    make && make bindir=/usr/sqlbox install

RUN mkdir /etc/kannel && \
    mkdir /var/log/kannel && \
    mkdir /var/spool/kannel && \
    chmod -R 755 /var/spool/kannel && \
    chmod -R 755 /var/log/kannel && \
    rm -r /src/*

COPY ./conf/kannel.default /etc/default/kannel
COPY ./conf/kannel.conf /etc/kannel/kannel.conf
COPY ./conf/smsbox.conf /etc/kannel/smsbox.conf
COPY ./conf/sqlbox.conf /etc/kannel/sqlbox.conf

VOLUME ["/var/spool/kannel", "/var/log/kannel", "/etc/kannel"]

FROM centos:7
MAINTAINER fzz

WORKDIR /root
COPY . /usr/src
#COPY . .

# 0. 依赖
RUN yum update -y \
    && yum install -y \
        numactl \
        autogen \
        autoconf \
        libaio-devel \
        net-tools \
        perl \
        perl-JSON \
        perl-Data-Dumper \
        telnet \
        net-tools \
        vim \
        wget \
        lrzsz \
        pkg-config \
        openssl \
        openssl-devel \
        git \
        tar \
        build-essential \
        gcc \
        libncurses5-dev \
        fop \
        xsltproc \
        ncurses-devel \
        unixodbc-dev \
        libssl-dev \
        && yum -y clean all

# 1. percona
ENV PERCONA_VERSION 5.7.18-15
COPY my.cnf /etc/my.cnf

ADD https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-${PERCONA_VERSION}/binary/redhat/7/x86_64/Percona-Server-${PERCONA_VERSION}-rbff2cd9-el7-x86_64-bundle.tar /usr/src
RUN cd /usr/src && tar -xvf /usr/src/Percona-Server-${PERCONA_VERSION}-*-el7-x86_64-bundle.tar \
        && rpm -ivh Percona-Server-server-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-client-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-shared-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-shared-compat-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-devel-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-57-debuginfo-${PERCONA_VERSION}.1.el7.x86_64.rpm 

# 2. go
ENV GO_VERSION 1.8.1
ENV OS linux
ENV ARCH amd64

ADD https://storage.googleapis.com/golang/go${VERSION}.${OS}-${ARCH}.tar.gz /usr/src/go${VERSION}.${OS}-${ARCH}.tar.gz
RUN tar -C /usr/local -xzf /usr/src/go${GO_VERSION}.${OS}-${ARCH}.tar.gz \
        && cd / && rm -rf /usr/src/go${GO_VERSION}.${OS}-${ARCH}.tar.gz

ENV GOROOT=/usr/local/go
ENV GOPATH=/root/work
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# 3. erlang
ENV OTP_VERSION 18.0
ENV REBAR_VERSION 2.6.4
ENV RELX_VERSION v3.23.0

ADD http://erlang.org/download/otp_src_${OTP_VERSION}.tar.gz /usr/src/
RUN cd /usr/src \
    && tar xf otp_src_${OTP_VERSION}.tar.gz \
    && cd otp_src_${OTP_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd / && rm -rf /usr/src/otp_src_${OTP_VERSION}

# 4. redis
ENV REDIS_VERSION 3.2.9
ADD http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz /usr/src
RUN cd /usr/src \
    && tar xzf redis-${REDIS_VERSION}.tar.gz \
    && cd redis-${REDIS_VERSION} \
    && make CFLAGS="-march=x86-64" \
    && make install \
    && cd / && rm -rf /usr/src/otp_src_${OTP_VERSION}

CMD ["/bin/bash"]

#!/bin/bash

ulimit -c unlimited
ROOT=`cd $(dirname $0); pwd`
DIR=${ROOT}

# 判断是否root
if [ $(id -u) != "0" ]; then
    echo " Not the root user! Try using sudo Command ! "
    exit 1
fi

# 0. 依赖
install_deps() {
    yum update -y \
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
        tar \
        build-essential \
        gcc \
        libncurses5-dev \
        fop \
        xsltproc \
        ncurses-devel \
        unixodbc-dev \
        libssl-dev \
        libcurl-devel \
        expat-devel \
        perl-ExtUtils-MakeMaker \
        python-setuptools \
        && yum -y clean all

    VERSION=1.0.0
    if [ ! -f "${DIR}/xlrd-${VERSION}.tar.gz" ]; then
        wget https://pypi.python.org/packages/42/85/25caf967c2d496067489e0bb32df069a8361e1fd96a7e9f35408e56b3aab/xlrd-${VERSION}.tar.gz -O ${DIR}/xlrd-${VERSION}.tar.gz
        tar zxvf ${DIR}/xlrd-${VERSION} .tar.gz \
            && cd xlrd-${VERSION}.tar.gz \
            python install setup.py
    fi      
}

# 1. percona
install_percona() {
    PERCONA_VERSION=5.7.18-15
    FILE=Percona-Server-${PERCONA_VERSION}-rbff2cd9-el7-x86_64-bundle.tar
    if [ ! -f "${DIR}/${FILE}" ]; then
        wget https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-${PERCONA_VERSION}/binary/redhat/7/x86_64/Percona-Server-${PERCONA_VERSION}-rbff2cd9-el7-x86_64-bundle.tar -O ${DIR}/Percona-Server-${PERCONA_VERSION}-rbff2cd9-el7-x86_64-bundle.tar
    fi
    tar xvf ${ROOT}/Percona-Server-${PERCONA_VERSION}-*-el7-x86_64-bundle.tar
    rpm -ivh Percona-Server-server-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-client-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-shared-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-shared-compat-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-devel-57-${PERCONA_VERSION}.1.el7.x86_64.rpm \
        Percona-Server-57-debuginfo-${PERCONA_VERSION}.1.el7.x86_64.rpm 

    mv /etc/my.cnf /etc/my.cnf.old
    cp ${ROOT}/my.cnf /etc/my.cnf
    service mysql start

    ########### something todo...
    #$ cat /var/log/mysqld.log | grep "temporary password"
    #$ mysql -uroot -p
    #$ mysql_secure_installation
}

# 2. go
install_go() {
    GO_VERSION=1.8.1
    OS=linux
    ARCH=amd64
    FILE=go${GO_VERSION}.${OS}-${ARCH}.tar.gz

    if [ ! -f "${DIR}/${FILE}" ]; then
        wget https://storage.googleapis.com/golang/go${VERSION}.${OS}-${ARCH}.tar.gz -O ${DIR}/${FILE}
    fi

    tar -C /usr/local -xzf ${ROOT}/go${GO_VERSION}.${OS}-${ARCH}.tar.gz 

    echo "GOROOT=/usr/local/go
    GOPATH=/${ROOT}/work
    PATH=${PATH}:${GOROOT}/bin:${GOPATH}/bin" >> ~/.bashrc
    source ~/.bashrc
}

# 3. erlang
install_erlang() {
    OTP_VERSION=18.0
    REBAR_VERSION=2.6.4
    RELX_VERSION=v3.23.0
    FILE=otp_src_${OTP_VERSION}.tar.gz

    if [ ! -f "${DIR}/${FILE}" ]; then
        wget http://erlang.org/download/${FILE} -O ${DIR}/${FILE}
    fi
    cd ${ROOT} \
        && tar xf otp_src_${OTP_VERSION}.tar.gz \
        && cd otp_src_${OTP_VERSION} \
        && ./configure \
        && make \
        && make install \
        && cd ${ROOT} && rm -rf ${ROOT}/otp_src_${OTP_VERSION}

    FILE=rebar-${REBAR_VERSION}.tar.gz
    if [ ! -f "${DIR}/${FILE}" ]; then
        wget https://github.com/rebar/rebar/archive/${REBAR_VERSION}.tar.gz -O ${DIR}/${FILE}
    fi
    cd ${ROOT} \
        && tar zxf rebar-${REBAR_VERSION}.tar.gz \
        && cd rebar-${REBAR_VERSION} \
        && make \
        && cp rebar /usr/bin/rebar \
        && cd ${ROOT} && rm -rf ${ROOT}/rebar-${REBAR_VERSION}

    FILE=relx-${RELX_VERSION}.tar.gz
    if [ ! -f "${DIR}/${FILE}" ]; then
        wget https://github.com/erlware/relx/archive/${RELX_VERSION}.tar.gz -O ${DIR}/${FILE}
    fi
    cd ${ROOT} \
        && tar zxf relx-${RELX_VERSION}.tar.gz \
        && cd relx-${RELX_VERSION#v} \
        && make \
        && cp relx /usr/bin/relx \
        && cd ${ROOT} && rm -rf ${ROOT}/relx-${RELX_VERSION}

    ########### something todo...
    #echo '[{debug_info, des3_cbc, [], "nananono_game_secret_key"}].' >> ~/.erlang.crypt
}

# 4. redis
install_redis() {
    REDIS_VERSION=3.2.9
    FILE=redis-${REDIS_VERSION}.tar.gz
    if [ ! -f "${DIR}/${FILE}" ]; then
        wget http://download.redis.io/releases/${FILE} -O ${DIR}/${FILE}
    fi
    cd ${ROOT} \
        && tar xzf redis-${REDIS_VERSION}.tar.gz \
        && cd redis-${REDIS_VERSION} \
        && make CFLAGS="-march=x86-64" \
        && make install \
        && cd ${ROOT} && rm -rf ${ROOT}/redis-${REDIS_VERSION}

    ########### something todo...
    #redis-server /usr/local/etc/redis/redis.conf
}

# 5. git
install_git() {
    GIT_VERSION=2.13.1
    FILE=git-${GET_VERSION}.tar.gz
    if [ ! -f "${DIR}/git-${GIT_VERSION}.tar.gz" ]; then
        wget https://github.com/git/git/archive/v$GIT_VERSION.tar.gz -O ${DIR}/${FILE}
    fi
    cd ${ROOT} \
        && tar xzf git-${GIT_VERSION}.tar.gz \
        && cd git-${GIT_VERSION} \
        && make configure \
        && ./configure --prefix=/usr \
        && make all \
        && make \
        && make install \
        && cd ${ROOT} && rm -rf ${ROOT}/git-${GIT_VERSION}
}

# 6. gitolite
create_git_user() {
    ssh-keygen -t rsa -C "git@localhost.domain"
    cp ~/.ssh/id_rsa.pub /tmp/id_rsa.pub
    chmod 644 /tmp/id_rsa.pub
    useradd git

}

install_gitolite() {
    # 判断是否git用户
    if [ `whoami` != "git" ];then
        echo " Not the git user! Try using sudo Command ! "
        exit 1
    fi

    #su - git
    git clone git://github.com/sitaramc/gitolite
    cd $HOME \
        && mkdir -p bin \
        && gitolite/install -to $HOME/bin \
        && cd $HOME \
        && $HOME/bin/gitolite setup -pk /tmp/id_rsa.pub

    ########### something todo...
    # go to workstaion
    # git ls-remote git@server:gitolite-admin
    # git clone git@server:gitolite-admin

    # workstation windows
    # git安装地址 https://git-scm.com/
    # key存放在C:\Users\Administrator\.ssh
}

# 7. node
install_node() {
    NODE_VERSION=v8.4.0
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
    source ~/.bashrc
    nvm install ${NODE_VERSION}
}

# 8. openresty
install_openresty() {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
    sudo yum install -y openresty
}

############################################
usage() {
    echo "Usage: $0 "
}

install() {
    install_deps
    install_percona
    install_go
    install_erlang
    install_redis
    install_git
    install_node
    install_openresty
}

###############
## start
###############
ACTION=$1
case ${ACTION} in
    'help') usage;;
*) install; exit 1;;
esac

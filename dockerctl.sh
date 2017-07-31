#!/bin/bash
ulimit -c unlimited

ROOT=`cd $(/usr/bin/dirname $0); pwd`
IMAGE_NAME=myos
CONTAINER=myos
DOCKER=/usr/bin/docker
PATH=.
DOCKER_FILE=Dockerfile
VOLUMES="-v /home/nana/data/mysql:/data/database/mysql -v /var/run/mysqld/:/var/run/mysqld/"
CMD=/bin/bash
EXPOSE="-p 3306:3306 -p 6379:6379 -p 4369:4369 -p 8080:8080"
NET="--net=host"

build() {
    $DOCKER build -f $DOCKER_FILE -t $IMAGE_NAME $PATH
}

rerun() {
    $DOCKER rm -v $CONTAINER
    /usr/bin/rm -rf /home/nana/data/mysql
    /usr/bin/chmod 777 /var/run/mysqld
    $DOCKER run -d -e "container=docker" --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup $VOLUMES $EXPOSE --name $CONTAINER $IMAGE_NAME /usr/sbin/init  

}

run() {
    $DOCKER run -d -e "container=docker" --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup $VOLUMES --name $CONTAINER $IMAGE_NAME /usr/sbin/init  
}

connect()  {
    $DOCKER exec -it $CONTAINER mysql -P 3306 --protocol=tcp --socket=/var/run/mysqld/mysql.sock -uroot -proot
}

start() {
    $DOCKER start $CONTAINER
}

stop() {
    $DOCKER stop $CONTAINER
}

attach() {
    $DOCKER exec -it $CONTAINER $CMD
}

exec() {
    CMD=$1
    $DOCKER exec -dit $CONTAINER $CMD
}

usage() {
    echo "Usage: $0 ACTION"
    echo "ACTION:"
    echo "start | stop | run | build"
}

###############
## start
###############
ACTION=$1
case ${ACTION} in
'') usage;;
'build') build;;
'run') run;;
'rerun') rerun;;
'start') start;;
'stop') stop;;
'attach') attach;;
'connect') connect;;
*) usage; exit 1;;
esac

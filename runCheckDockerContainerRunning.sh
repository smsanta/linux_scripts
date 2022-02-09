SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0 $1

dockerCheck=$(docker container ls -a | grep oracle-db-12c-r2 | grep Up)

if [ -z "$dockerCheck" ]; then
    echo "Docker - oracle-db-12c-r2 - Is NOT Running."
else
    echo "Docker - oracle-db-12c-r2 - Is Running."
fi
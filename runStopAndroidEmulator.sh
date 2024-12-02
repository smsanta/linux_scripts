SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0 $1

ps ax | grep 'qemu' | awk '{print $1}' | xargs kill -9
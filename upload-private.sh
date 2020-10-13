#!/bin/sh

exit

#lftp login info
user='fill me'
server='fill me'

script_path=`readlink -f $0`
script_dir=`dirname $script_path`
local_dir=$script_dir/public

sh $script_dir/upload-public.sh $user $server

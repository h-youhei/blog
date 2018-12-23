#!/bin/sh

if [ $# -ne 2 ];
then
	echo "bad argument"
	exit 1
fi

script_path=`readlink -f $0`
script_dir=`dirname $script_path`
local_dir=$script_dir/public

# --ignore-time due to hugo regenerate all files
# -R local to remote
# -e delete
lftp -u $1 $2 <<EOF
	mirror -R -e --ignore-time $local_dir /
EOF

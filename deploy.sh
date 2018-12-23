#!/bin/sh

script_path=`readlink -f $0`
script_dir=`dirname $script_path`

sh $script_dir/build.sh
sh $script_dir/upload.sh

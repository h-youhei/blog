#!/bin/sh

script_path=`readlink -f $0`
script_dir=`dirname $script_path`
cd $script_dir

hugo --cleanDestinationDir --minify
cd public

#delete unnecessary files generated
#rm -r ja

fd -e html -e js -e css \
	-x gzip -k
	# -e xml--exclude sitemap.xml \

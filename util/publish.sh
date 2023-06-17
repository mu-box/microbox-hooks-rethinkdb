#!/bin/bash

stability=$1

util_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(dirname $util_dir)"

# ensure the build dir exists
mkdir -p $project_dir/.build

echo "Generating tarball..."
tar -cvz -C $project_dir/src -f $project_dir/.build/rethinkdb-${stability}.tgz .

echo "Generating md5..."
cat $project_dir/.build/rethinkdb-${stability}.tgz | md5 > $project_dir/.build/rethinkdb-${stability}.md5

echo "Uploading builds to s3..."
aws s3 sync \
  $project_dir/.build/ \
  s3://tools.microbox.cloud/hooks \
  --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
  --region us-east-1

# echo "Creating invalidation for cloudfront"
# aws  configure  set preview.cloudfront true
# aws cloudfront create-invalidation \
#   --distribution-id E1O0D0A2DTYRY8 \
#   --paths /hooks/rethinkdb-${stability}.tgz /hooks/rethinkdb-${stability}.md5

echo "Cleaning..."
rm -rf $project_dir/.build
